import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/localization/app_localizations.dart';

// Simple state provider for speaker request
final speakerRequestProvider =
    StateNotifierProvider<SpeakerRequestNotifier, SpeakerRequestState>((ref) {
      return SpeakerRequestNotifier();
    });

class SpeakerRequestState {
  final bool hasRequested;
  final bool isSpeaking;
  final int queuePosition;
  final int speakingTime; // in seconds

  SpeakerRequestState({
    this.hasRequested = false,
    this.isSpeaking = false,
    this.queuePosition = 0,
    this.speakingTime = 0,
  });

  SpeakerRequestState copyWith({
    bool? hasRequested,
    bool? isSpeaking,
    int? queuePosition,
    int? speakingTime,
  }) {
    return SpeakerRequestState(
      hasRequested: hasRequested ?? this.hasRequested,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      queuePosition: queuePosition ?? this.queuePosition,
      speakingTime: speakingTime ?? this.speakingTime,
    );
  }
}

class SpeakerRequestNotifier extends StateNotifier<SpeakerRequestState> {
  SpeakerRequestNotifier() : super(SpeakerRequestState());

  void requestToSpeak() {
    state = state.copyWith(hasRequested: true, queuePosition: 3);
  }

  void cancelRequest() {
    state = state.copyWith(hasRequested: false, queuePosition: 0);
  }

  void startSpeaking() {
    state = state.copyWith(isSpeaking: true, hasRequested: false);
  }

  void stopSpeaking() {
    state = state.copyWith(isSpeaking: false, speakingTime: 0);
  }
}

class SpeakerScreen extends ConsumerWidget {
  const SpeakerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speakerState = ref.watch(speakerRequestProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: l10n.speakerRequest, showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!speakerState.hasRequested && !speakerState.isSpeaking) ...[
              // Request to Speak
              FadeInDown(
                child: const Icon(
                  Icons.mic_none,
                  size: 120,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  l10n.requestToSpeak,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  l10n.tapButtonToRequest,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(speakerRequestProvider.notifier)
                          .requestToSpeak();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.requestSentToAdmin),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.record_voice_over, size: 28),
                    label: Text(
                      l10n.requestToSpeak,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ] else if (speakerState.hasRequested &&
                !speakerState.isSpeaking) ...[
              // Waiting in Queue
              FadeInDown(
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 120,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  l10n.requestPending,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.yourPositionInQueue,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '#${speakerState.queuePosition}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  l10n.pleaseWaitForPermission,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(speakerRequestProvider.notifier).cancelRequest();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.requestCancelled),
                          backgroundColor: AppColors.textSecondary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.cancel),
                    label: Text(l10n.cancelRequest),
                  ),
                ),
              ),
            ] else if (speakerState.isSpeaking) ...[
              // Speaking
              FadeIn(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withOpacity(0.1),
                    border: Border.all(color: AppColors.success, width: 4),
                  ),
                  child: const Center(
                    child: Icon(Icons.mic, size: 80, color: AppColors.success),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Pulse(
                infinite: true,
                child: Text(
                  l10n.micOn,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.youAreCurrentlySpeaking,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.speakingTime,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '2:34',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(speakerRequestProvider.notifier).stopSpeaking();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.microphoneTurnedOff),
                        backgroundColor: AppColors.textSecondary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.mic_off, size: 28),
                  label: Text(
                    l10n.turnOffMic,
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
