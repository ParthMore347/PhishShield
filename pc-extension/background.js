// PhishShield Chrome MV3 Background Service Worker
// Proactive Tab Monitoring, Badge Telemetry & Malicious Interception

const API_ENDPOINT = "http://localhost:8000/api/scan";
const whitelistedUrls = new Set();

// Helper to determine if URL should be inspected
function isInspectableUrl(url) {
    if (!url) return false;
    const lower = url.toLowerCase();
    return !(
        lower.startsWith("chrome://") ||
        lower.startsWith("chrome-extension://") ||
        lower.startsWith("edge://") ||
        lower.startsWith("about:") ||
        lower.startsWith("view-source:")
    );
}

// Set extension badge status
function setBadge(tabId, text, color) {
    if (typeof chrome.action !== "undefined") {
        chrome.action.setBadgeText({ tabId, text });
        chrome.action.setBadgeBackgroundColor({ tabId, color });
    }
}

// Active Scan & Interception Routine
async function inspectTabUrl(tabId, url) {
    if (!isInspectableUrl(url)) {
        setBadge(tabId, "", "#64748b");
        return;
    }

    if (whitelistedUrls.has(url)) {
        setBadge(tabId, "BYP", "#f59e0b");
        return;
    }

    try {
        const response = await fetch(API_ENDPOINT, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ url: url, platform: "extension_background" })
        });

        if (!response.ok) {
            console.warn("[PhishShield BG] API check non-200 status:", response.status);
            return;
        }

        const data = await response.json();
        const verdict = data.verdict; // SAFE, SUSPICIOUS, MALICIOUS
        const confidencePct = Math.round((data.overall_confidence || 0.8) * 100);

        if (verdict === "SAFE") {
            setBadge(tabId, "✓", "#10b981");
        } else if (verdict === "SUSPICIOUS") {
            setBadge(tabId, "!", "#f59e0b");
        } else if (verdict === "MALICIOUS") {
            setBadge(tabId, "✕", "#ef4444");

            // Intercept tab navigation and redirect to full-screen warning block page
            const blockPageUrl = chrome.runtime.getURL("block.html") + 
                `?url=${encodeURIComponent(url)}` +
                `&confidence=${confidencePct}%` +
                `&scanId=${data.scan_id || 'PS-ACTIVE'}`;

            chrome.tabs.update(tabId, { url: blockPageUrl });

            // Trigger system desktop notification
            if (chrome.notifications) {
                chrome.notifications.create({
                    type: "basic",
                    iconUrl: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23ef4444'><path d='M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z'/></svg>",
                    title: "PhishShield Threat Intercepted",
                    message: `Blocked malicious destination: ${url.substring(0, 48)}...`,
                    priority: 2
                });
            }
        }
    } catch (err) {
        console.warn("[PhishShield BG] Could not reach PhishShield backend:", err.message);
    }
}

// Tab navigation listener
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (changeInfo.status === "complete" && tab.url) {
        inspectTabUrl(tabId, tab.url);
    }
});

// Tab focus change listener
chrome.tabs.onActivated.addListener(async (activeInfo) => {
    try {
        const tab = await chrome.tabs.get(activeInfo.tabId);
        if (tab && tab.url) {
            inspectTabUrl(tab.id, tab.url);
        }
    } catch (e) {
        // Tab might have been closed immediately
    }
});

// Message listener for whitelist bypass from block.js
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === "whitelist_url" && request.url) {
        whitelistedUrls.add(request.url);
        sendResponse({ status: "whitelisted" });
    }
    return true;
});
