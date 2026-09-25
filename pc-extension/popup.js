document.addEventListener('DOMContentLoaded', async () => {
    const targetUrlEl = document.getElementById('target-url');
    const scanBtn = document.getElementById('scan-btn');
    const btnText = document.getElementById('btn-text');
    const btnSpinner = document.getElementById('btn-spinner');
    const resultsPanel = document.getElementById('results-panel');
    const verdictBanner = document.getElementById('verdict-banner');
    const verdictStatus = document.getElementById('verdict-status');
    const verdictConfidence = document.getElementById('verdict-confidence');
    const verdictIcon = document.getElementById('verdict-icon');
    const engineStatus = document.getElementById('engine-status');
    const protocolBadge = document.getElementById('protocol-badge');
    const blockPreviewBox = document.getElementById('block-preview-box');
    const btnViewBlock = document.getElementById('btn-view-block');
    
    const hScore = document.getElementById('heuristics-score');
    const hDesc = document.getElementById('heuristics-desc');
    const nScore = document.getElementById('nlp-score');
    const nDesc = document.getElementById('nlp-desc');

    const vectorChips = document.querySelectorAll('.chip-btn');

    let currentUrl = '';
    let lastScanData = null;

    // Check Backend Server Health Status
    async function checkHealth() {
        try {
            const res = await fetch('http://localhost:8000/', { method: 'GET' });
            if (res.ok) {
                engineStatus.innerHTML = '<span class="status-dot"></span><span>ONLINE</span>';
                engineStatus.style.color = '#34d399';
            } else {
                throw new Error();
            }
        } catch (e) {
            engineStatus.innerHTML = '<span class="status-dot" style="background:#ef4444;box-shadow:0 0 6px #ef4444"></span><span>OFFLINE</span>';
            engineStatus.style.color = '#f87171';
        }
    }
    checkHealth();

    // 1. Get the current active tab
    try {
        if (typeof chrome !== 'undefined' && chrome.tabs) {
            const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
            if (tab && tab.url) {
                currentUrl = tab.url;
                targetUrlEl.textContent = currentUrl;
                updateProtocolBadge(currentUrl);
            } else {
                targetUrlEl.textContent = 'Unable to read active tab URL';
            }
        } else {
            // Mock environment fallback for browser testing
            currentUrl = 'https://signin.paypal-account-security-update.xyz/login';
            targetUrlEl.textContent = currentUrl;
            updateProtocolBadge(currentUrl);
        }
    } catch (err) {
        targetUrlEl.textContent = 'Error reading active tab';
        console.error(err);
    }

    function updateProtocolBadge(url) {
        if (url.startsWith('https://')) {
            protocolBadge.textContent = 'HTTPS';
            protocolBadge.style.color = '#34d399';
        } else if (url.startsWith('http://')) {
            protocolBadge.textContent = 'HTTP (INSECURE)';
            protocolBadge.style.color = '#f87171';
        } else {
            protocolBadge.textContent = 'INTERNAL';
            protocolBadge.style.color = '#94a3b8';
        }
    }

    // 2. Test Vector Chip Click Listeners
    vectorChips.forEach(chip => {
        chip.addEventListener('click', () => {
            const vectorUrl = chip.getAttribute('data-url');
            currentUrl = vectorUrl;
            targetUrlEl.textContent = currentUrl;
            updateProtocolBadge(currentUrl);
            // Trigger automatic scan for demo convenience
            triggerScan();
        });
    });

    // 3. Scan Button Handler
    scanBtn.addEventListener('click', () => {
        triggerScan();
    });

    async function triggerScan() {
        if (!currentUrl) {
            targetUrlEl.textContent = 'No valid URL to scan';
            return;
        }

        scanBtn.disabled = true;
        btnText.textContent = 'Scanning Link...';
        btnSpinner.classList.remove('hidden');
        resultsPanel.classList.add('hidden');
        blockPreviewBox.classList.add('hidden');

        try {
            const response = await fetch('http://localhost:8000/api/scan', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    url: currentUrl,
                    platform: 'extension'
                })
            });

            if (!response.ok) {
                throw new Error('API server returned error status ' + response.status);
            }

            const data = await response.json();
            lastScanData = data;
            displayResults(data);
        } catch (error) {
            console.error('Scan Error:', error);
            showError('OFFLINE', 'Backend service unreachable. Run `uvicorn app.main:app --reload` on port 8000.');
        } finally {
            scanBtn.disabled = false;
            btnText.textContent = 'Deep Scan Link';
            btnSpinner.classList.add('hidden');
        }
    }

    function displayResults(data) {
        resultsPanel.classList.remove('hidden');
        verdictBanner.className = 'verdict-banner';
        
        const status = data.verdict; // SAFE, SUSPICIOUS, MALICIOUS
        verdictStatus.textContent = status;
        verdictConfidence.textContent = `Confidence: ${Math.round(data.overall_confidence * 100)}%`;
        
        if (status === 'SAFE') {
            verdictBanner.classList.add('safe');
            verdictIcon.textContent = '🛡️';
            blockPreviewBox.classList.add('hidden');
        } else if (status === 'SUSPICIOUS') {
            verdictBanner.classList.add('suspicious');
            verdictIcon.textContent = '⚠️';
            blockPreviewBox.classList.add('hidden');
        } else {
            verdictBanner.classList.add('malicious');
            verdictIcon.textContent = '🚨';
            // Reveal Interstitial Block Preview Button
            blockPreviewBox.classList.remove('hidden');
        }

        // Heuristics breakdown
        const hData = data.engine_results.heuristics;
        hScore.textContent = `${Math.round(hData.score * 100)}%`;
        hDesc.innerHTML = `
            Suspicious TLD: <strong>${hData.suspicious_tld ? 'Yes (.xyz/.top)' : 'No'}</strong><br/>
            IP Address Domain: <strong>${hData.has_ip_address ? 'Yes' : 'No'}</strong><br/>
            Domain Length: <strong>${hData.domain_length} chars</strong>
        `;

        // NLP breakdown
        const nData = data.engine_results.nlp;
        if (nData) {
            nScore.textContent = `${Math.round(nData.score * 100)}%`;
            const keywords = nData.suspicious_keywords_found.length > 0 
                ? nData.suspicious_keywords_found.join(', ') 
                : 'None';
            nDesc.innerHTML = `
                Target Keywords: <strong>${keywords}</strong><br/>
                Urgency detected: <strong>${nData.sentiment_anomaly ? 'Yes (Social Engineering)' : 'No'}</strong>
            `;
        } else {
            nScore.textContent = 'N/A';
            nDesc.textContent = 'No NLP analysis performed.';
        }
    }

    function showError(status, message) {
        resultsPanel.classList.remove('hidden');
        verdictBanner.className = 'verdict-banner malicious';
        verdictStatus.textContent = status;
        verdictIcon.textContent = '❌';
        verdictConfidence.textContent = 'Offline';
        
        hScore.textContent = 'ERR';
        hDesc.textContent = message;
        nScore.textContent = 'ERR';
        nDesc.textContent = 'FastAPI connection offline.';
    }

    // Interstitial Warning Block Preview
    btnViewBlock.addEventListener('click', () => {
        const confidencePct = lastScanData ? Math.round(lastScanData.overall_confidence * 100) : 92;
        const blockUrl = `block.html?url=${encodeURIComponent(currentUrl)}&confidence=${confidencePct}%&scanId=${lastScanData?.scan_id || 'PS-DEMO'}`;
        
        if (typeof chrome !== 'undefined' && chrome.tabs) {
            chrome.tabs.create({ url: chrome.runtime.getURL(blockUrl) });
        } else {
            window.open(blockUrl, '_blank');
        }
    });
});
