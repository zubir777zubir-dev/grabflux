import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/download_model.dart';
import '../services/cobalt_service.dart';
import '../widgets/platform_selector.dart';
import '../widgets/format_selector.dart';
import '../widgets/quality_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  Platform _platform = Platform.youtube;
  Format _format = Format.mp4;
  Quality _quality = Quality.q720;
  bool _loading = false;
  String? _error;
  CobaltResult? _result;

  late AnimationController _bgController;
  late AnimationController _btnController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _btnController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
      setState(() {
        _error = null;
        _result = null;
      });
    }
  }

  Future<void> _download() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'من فضلك أدخل الرابط أولاً');
      return;
    }
    if (!_platform.validateUrl(url)) {
      setState(() => _error = 'الرابط لا يتطابق مع المنصة المختارة');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    HapticFeedback.mediumImpact();

    final req = DownloadRequest(
      url: url,
      platform: _platform,
      format: _format,
      quality: _quality,
    );

    final result = await CobaltService.fetchDownloadUrl(req);

    setState(() {
      _loading = false;
      if (result.success) {
        _result = result;
        HapticFeedback.heavyImpact();
      } else {
        _error = result.error ?? 'حدث خطأ غير متوقع';
      }
    });
  }

  Future<void> _openDownloadUrl() async {
    if (_result?.downloadUrl == null) return;
    final uri = Uri.parse(_result!.downloadUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Animated background orbs
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) {
              return Stack(
                children: [
                  Positioned(
                    top: -100 + (_bgController.value * 30),
                    left: -80,
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF7C6AF0).withOpacity(0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0 + (_bgController.value * -20),
                    right: -60,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF4ADE80).withOpacity(0.07),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  PlatformSelector(
                    selected: _platform,
                    onChanged: (p) => setState(() {
                      _platform = p;
                      _error = null;
                      _result = null;
                      _urlController.clear();
                    }),
                  ),
                  const SizedBox(height: 20),
                  _buildUrlInput(),
                  const SizedBox(height: 16),
                  FormatSelector(
                    selected: _format,
                    onChanged: (f) => setState(() => _format = f),
                  ),
                  if (_format == Format.mp4) ...[
                    const SizedBox(height: 16),
                    QualitySelector(
                      selected: _quality,
                      onChanged: (q) => setState(() => _quality = q),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (_error != null) _buildError(),
                  _buildDownloadButton(),
                  if (_result != null && _result!.success) ...[
                    const SizedBox(height: 16),
                    _buildResultCard(),
                  ],
                  const SizedBox(height: 24),
                  _buildNotice(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C6AF0), Color(0xFFA594F7)],
                ),
              ),
              child: const Center(
                child: Text('⬇', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SpaceGrotesk',
                ),
                children: [
                  TextSpan(text: 'Grab', color: Colors.white),
                  TextSpan(
                    text: 'Flux',
                    style: TextStyle(color: Color(0xFFA594F7)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.15,
              fontFamily: 'SpaceGrotesk',
            ),
            children: [
              TextSpan(text: 'حمّل أي فيديو\n', style: TextStyle(color: Colors.white)),
              TextSpan(
                text: 'بجودة عالية',
                style: TextStyle(color: Color(0xFFA594F7)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'يوتيوب، تيك توك، إنستغرام — بدون علامة مائية',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF9B96C8),
            fontWeight: FontWeight.w300,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildUrlInput() {
    return Container(
      padding: const EdgeInsets.only(left: 18, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2840)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: _platform.placeholder,
                hintStyle: const TextStyle(color: Color(0xFF5A5580), fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (_) => setState(() {
                _error = null;
                _result = null;
              }),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _pasteFromClipboard,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A24),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2840)),
              ),
              child: const Text(
                '📋 لصق',
                style: TextStyle(fontSize: 13, color: Color(0xFF9B96C8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE24B4A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE24B4A).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFF09595),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return GestureDetector(
      onTap: _loading ? null : _download,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _loading
              ? const LinearGradient(
                  colors: [Color(0xFF3D3A60), Color(0xFF3D3A60)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C6AF0), Color(0xFFA594F7)],
                ),
          boxShadow: _loading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF7C6AF0).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: _loading
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white54,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'جاري المعالجة...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⬇', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Text(
                      'تحميل الآن',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2840)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _platform.icon,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  '✅ جاهز للتحميل',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4ADE80),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${_platform.label} — ${_format == Format.mp3 ? "ملف صوتي MP3" : "فيديو ${_quality.label} MP4"}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            children: [
              _buildMetaBadge('📦 ${_format.name.toUpperCase()}'),
              if (_format == Format.mp4)
                _buildMetaBadge('🎯 ${_quality.label}'),
              _buildMetaBadge('✅ بدون علامة مائية'),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _openDownloadUrl,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF4ADE80),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⬇', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'تحميل الملف',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A150F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_result?.pickerItems != null &&
              _result!.pickerItems!.length > 1) ...[
            const SizedBox(height: 12),
            const Text(
              'ملفات إضافية متاحة:',
              style: TextStyle(fontSize: 12, color: Color(0xFF9B96C8)),
            ),
            const SizedBox(height: 8),
            ...(_result!.pickerItems!.skip(1).take(3).map((item) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(item.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A24),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF2A2840)),
                      ),
                      child: Row(
                        children: [
                          const Text('📎',
                              style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          const Text(
                            'تحميل ملف إضافي',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF9B96C8)),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios,
                              size: 12, color: Color(0xFF5A5580)),
                        ],
                      ),
                    ),
                  ),
                ))),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaBadge(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2840)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Color(0xFF9B96C8)),
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2840)),
      ),
      child: const Text(
        '⚠️ هذا التطبيق للاستخدام الشخصي فقط. يرجى احترام حقوق الملكية الفكرية. يعتمد على خدمة cobalt.tools المفتوحة المصدر.',
        style: TextStyle(
          fontSize: 11,
          color: Color(0xFF5A5580),
          height: 1.7,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
