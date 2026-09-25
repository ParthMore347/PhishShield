document.addEventListener('DOMContentLoaded', () => {
    const blockedUrlEl = document.getElementById('blocked-url');
    const threatTagEl = document.getElementById('threat-tag');
    const diagHeuristicsEl = document.getElementById('diag-heuristics');
    const diagNlpEl = document.getElementById('diag-nlp');
    const scanIdEl = document.getElementById('scan-id');
    const timestampTextEl = document.getElementById('timestamp-text');

    const btnSafety = document.getElementById('btn-safety');
    const btnBypassToggle = document.getElementById('btn-bypass-toggle');
    const bypassPanel = document.getElementById('bypass-panel');
    const btnBypassConfirm = document.getElementById('btn-bypass-confirm');

    // Extract query parameters
    const urlParams = new URLSearchParams(window.location.search);
    const targetUrl = urlParams.get('url') || 'https://threat-sample.phishshield.internal/login';
    const confidence = urlParams.get('confidence') || '92%';
    const scanId = urlParams.get('scanId') || 'PS-' + Math.random().toString(36).substring(2, 9).toUpperCase();
    const heuristicMsg = urlParams.get('heuristic') || 'Abnormal subdomain entropy, suspicious TLD (.xyz), and disguised structure detected.';
    const nlpMsg = urlParams.get('nlp') || 'Target brand spoofing patterns detected with urgent action lures.';

    // Populate elements
    blockedUrlEl.textContent = targetUrl;
    threatTagEl.textContent = `MALICIOUS (${confidence} CONFIDENCE)`;
    diagHeuristicsEl.textContent = heuristicMsg;
    diagNlpEl.textContent = nlpMsg;
    scanIdEl.textContent = scanId;
    timestampTextEl.textContent = new Date().toUTCString();

    // 1. Safety Button: Return to safe blank page or Google
    btnSafety.addEventListener('click', () => {
        if (typeof chrome !== 'undefined' && chrome.tabs) {
            chrome.tabs.getCurrent((tab) => {
                if (tab && tab.id) {
                    chrome.tabs.update(tab.id, { url: 'https://www.google.com' });
                } else {
                    window.location.href = 'https://www.google.com';
                }
            });
        } else {
            window.location.href = 'https://www.google.com';
        }
    });

    // 2. Bypass Toggle
    btnBypassToggle.addEventListener('click', () => {
        bypassPanel.classList.toggle('hidden');
    });

    // 3. Confirm Bypass: Navigate to target anyway
    btnBypassConfirm.addEventListener('click', () => {
        const proceed = confirm(
            "PHISHSHIELD SECURITY OVERRIDE\n\n" +
            "You are bypassing safety mechanisms to open a confirmed malicious website.\n" +
            "Are you absolutely certain you want to proceed?"
        );
        if (proceed) {
            // If in extension, communicate whitelist bypass to background script
            if (typeof chrome !== 'undefined' && chrome.runtime) {
                chrome.runtime.sendMessage({
                    action: 'whitelist_url',
                    url: targetUrl
                }, () => {
                    window.location.href = targetUrl;
                });
            } else {
                window.location.href = targetUrl;
            }
        }
    });
});
