import 'package:flutter/material.dart';

class TacticalScoreCard extends StatefulWidget {
  final Map<String, dynamic> scanDetails;
  final VoidCallback? onHelpPressed;

  const TacticalScoreCard({
    super.key,
    required this.scanDetails,
    this.onHelpPressed,
  });

  @override
  State<TacticalScoreCard> createState() => _TacticalScoreCardState();
}

class _TacticalScoreCardState extends State<TacticalScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final targetScore = _getTargetPercentage();
    _scoreAnimation = Tween<double>(begin: 0.0, end: targetScore).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant TacticalScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scanDetails != widget.scanDetails) {
      final targetScore = _getTargetPercentage();
      _scoreAnimation = Tween<double>(begin: 0.0, end: targetScore).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double _getTargetPercentage() {
    final verdict = (widget.scanDetails['verdict'] as String?)?.toUpperCase() ?? 'UNKNOWN';
    final rawRisk = ((widget.scanDetails['risk_score'] ??
            widget.scanDetails['overall_confidence'] ??
            0.0) as num)
        .toDouble();

    if (verdict == 'SAFE') {
      return ((1.0 - rawRisk) * 100).clamp(0.0, 100.0);
    }
    return (rawRisk * 100).clamp(0.0, 100.0);
  }

  Color _getTierColor(String verdict) {
    switch (verdict.toUpperCase()) {
      case 'SAFE':
        return const Color(0xFF00E676); // Emerald
      case 'SUSPICIOUS':
        return const Color(0xFFFFB300); // Amber
      case 'MALICIOUS':
        return const Color(0xFFFF1744); // Crimson
      default:
        return const Color(0xFF94A3B8); // Slate
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verdict = (widget.scanDetails['verdict'] as String?)?.toUpperCase() ?? 'UNKNOWN';
    final tierColor = _getTierColor(verdict);
    final isSafe = verdict == 'SAFE';
    final scoreSuffix = isSafe ? '% Safe' : '% Threat';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? const Color(0xFF0D0F12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tierColor.withValues(alpha: 0.75),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.22),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Verdict icon + label and animated score badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        verdict == 'MALICIOUS'
                            ? Icons.dangerous_rounded
                            : verdict == 'SUSPICIOUS'
                                ? Icons.warning_amber_rounded
                                : Icons.verified_user_rounded,
                        color: tierColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AUDIT VERDICT',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.0,
                              fontWeight: FontWeight.bold,
                              color: tierColor.withValues(alpha: 0.8),
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            verdict,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: tierColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Animated Dial / Badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _scoreAnimation,
                    builder: (context, child) {
                      final currentScore = _scoreAnimation.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: tierColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: tierColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                value: (currentScore / 100.0).clamp(0.0, 1.0),
                                strokeWidth: 2.0,
                                backgroundColor: tierColor.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${currentScore.round()}$scoreSuffix',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: tierColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (widget.onHelpPressed != null) ...[
                    IconButton(
                      icon: Icon(
                        Icons.help_outline_rounded,
                        size: 19,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.only(left: 4),
                      constraints: const BoxConstraints(),
                      tooltip: 'Threat Scoring Standard',
                      onPressed: widget.onHelpPressed,
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Target URL
          if (widget.scanDetails['url'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.link,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.scanDetails['url']}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Signals Section
          if (widget.scanDetails['signals'] != null &&
              (widget.scanDetails['signals'] as List).isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.radar, size: 14, color: tierColor),
                const SizedBox(width: 6),
                const Text(
                  'SECURITY INDICATORS DETECTED:',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...((widget.scanDetails['signals'] as List).map(
              (sig) => Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_right_rounded,
                      size: 18,
                      color: tierColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        sig.toString(),
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],

          const Divider(height: 24),

          // Multi-Engine Breakdown
          Row(
            children: [
              Icon(Icons.memory, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              const Text(
                'MULTI-ENGINE BREAKDOWN & DIAGNOSTICS:',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetricChip(
                label: 'Heuristics',
                value: '${((widget.scanDetails['engine_results']?['heuristics']?['score'] ?? 0.0) * 100).round()}%',
              ),
              _buildMetricChip(
                label: 'NLP Keywords',
                value: '${((widget.scanDetails['engine_results']?['nlp']?['score'] ?? 0.0) * 100).round()}%',
              ),
              if (widget.scanDetails['engine_results']?['heuristics']?['url_entropy'] != null)
                _buildMetricChip(
                  label: 'Entropy',
                  value: '${widget.scanDetails['engine_results']?['heuristics']?['url_entropy']}',
                ),
              if (widget.scanDetails['engine_results']?['heuristics']?['is_dynamic_dns'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Dynamic DNS Host',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFB300),
                    ),
                  ),
                ),
              if (widget.scanDetails['engine_results']?['heuristics']?['suspicious_tld'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF1744).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFF1744).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Suspicious TLD',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF1744),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 11,
          fontFamily: 'monospace',
          color: Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}
