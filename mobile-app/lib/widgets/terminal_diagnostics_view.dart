import 'dart:async';
import 'package:flutter/material.dart';

enum DiagnosticType { url, qr, sms }

class TerminalDiagnosticsView extends StatefulWidget {
  final DiagnosticType type;
  final String target;
  final VoidCallback? onCompleted;

  const TerminalDiagnosticsView({
    super.key,
    this.type = DiagnosticType.url,
    required this.target,
    this.onCompleted,
  });

  @override
  State<TerminalDiagnosticsView> createState() => _TerminalDiagnosticsViewState();
}

class _TerminalDiagnosticsViewState extends State<TerminalDiagnosticsView>
    with SingleTickerProviderStateMixin {
  late final List<_DiagnosticStep> _allSteps;
  final List<_DiagnosticStep> _displayedSteps = [];
  Timer? _stepTimer;
  Timer? _cursorTimer;
  bool _showCursor = true;
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _initSteps();
    _startTerminalSequence();
  }

  void _initSteps() {
    switch (widget.type) {
      case DiagnosticType.url:
        _allSteps = [
          const _DiagnosticStep('0.04s', 'INIT', 'Initializing multi-engine telemetry pipeline...'),
          const _DiagnosticStep('0.18s', 'DNS ', 'Querying A/AAAA, MX records & nameserver reputation...'),
          const _DiagnosticStep('0.35s', 'TLS ', 'Inspecting SSL/TLS certificate chain & cipher validity...'),
          const _DiagnosticStep('0.52s', 'MATH', 'Evaluating Shannon Entropy & character distribution...'),
          const _DiagnosticStep('0.74s', 'NLP ', 'Scanning intent vectors for credential-harvesting markers...'),
          const _DiagnosticStep('0.96s', 'ATLS', 'Cross-referencing Threat Intelligence Atlas & blocklists...'),
          const _DiagnosticStep('1.15s', 'DONE', 'Synthesizing deterministic multi-vector verdict...'),
        ];
        break;
      case DiagnosticType.qr:
        _allSteps = [
          const _DiagnosticStep('0.05s', 'INIT', 'Extracting barcode payload from camera buffer...'),
          const _DiagnosticStep('0.20s', 'CODE', 'De-obfuscating embedded URL & URI schema...'),
          const _DiagnosticStep('0.40s', 'TRCE', 'Tracing unverified redirect hops & shortener targets...'),
          const _DiagnosticStep('0.65s', 'EVAL', 'Analyzing destination domain age & Dynamic DNS markers...'),
          const _DiagnosticStep('0.85s', 'ATLS', 'Checking QR phishing database & Atlas indicators...'),
          const _DiagnosticStep('1.05s', 'DONE', 'Compiling QR risk index score...'),
        ];
        break;
      case DiagnosticType.sms:
        _allSteps = [
          const _DiagnosticStep('0.05s', 'INIT', 'Tokenizing SMS message body & lexical structure...'),
          const _DiagnosticStep('0.22s', 'SENT', 'Parsing urgency keywords & social engineering cues...'),
          const _DiagnosticStep('0.45s', 'EXTR', 'Isolating embedded hyperlinks & delivery spoof vectors...'),
          const _DiagnosticStep('0.70s', 'NLP ', 'Evaluating contextual NLP intent against phishing corpora...'),
          const _DiagnosticStep('0.92s', 'ATLS', 'Matching sender footprint against known smishing campaigns...'),
          const _DiagnosticStep('1.10s', 'DONE', 'Generating comprehensive smishing risk assessment...'),
        ];
        break;
    }
  }

  void _startTerminalSequence() {
    // Blinking cursor
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      }
    });

    // Reveal steps sequentially every ~190ms
    _stepTimer = Timer.periodic(const Duration(milliseconds: 190), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentStepIndex < _allSteps.length) {
        setState(() {
          _displayedSteps.add(_allSteps[_currentStepIndex]);
          _currentStepIndex++;
        });
      } else {
        timer.cancel();
        widget.onCompleted?.call();
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isCyberpunk = primaryColor == const Color(0xFFFF007F);
    final consoleAccent = isCyberpunk ? const Color(0xFFFF007F) : const Color(0xFF00E5FF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: consoleAccent.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: consoleAccent.withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tactical Header
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: consoleAccent,
                  boxShadow: [
                    BoxShadow(
                      color: consoleAccent,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'DIAGNOSTICS CONSOLE // SOC PROBE ACTIVE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: consoleAccent,
                ),
              ),
              const Spacer(),
              Text(
                'ENCRYPTED',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            color: consoleAccent.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 10),

          // Target line
          if (widget.target.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '> TARGET: ${widget.target}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),

          // Diagnostic step entries
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _displayedSteps.length,
            itemBuilder: (context, index) {
              final step = _displayedSteps[index];
              final isLatest = index == _displayedSteps.length - 1;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '[+${step.timestamp}]',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '[${step.tag}]',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: step.tag == 'DONE'
                            ? const Color(0xFF00E676)
                            : consoleAccent.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        step.message,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: isLatest ? Colors.white : const Color(0xFFCBD5E1),
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Blinking cursor active prompt
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Text(
                  '> ',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: consoleAccent,
                  ),
                ),
                Text(
                  _currentStepIndex >= _allSteps.length ? 'Awaiting response packet...' : 'Processing telemetry...',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (_showCursor)
                  Text(
                    ' _',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: consoleAccent,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticStep {
  final String timestamp;
  final String tag;
  final String message;

  const _DiagnosticStep(this.timestamp, this.tag, this.message);
}
