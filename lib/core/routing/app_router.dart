import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_credentials_screen.dart';
import '../../features/auth/presentation/screens/code_verification_screen.dart';
import '../../features/auth/presentation/screens/password_screen.dart';
import '../../features/drive/presentation/screens/drive_home_screen.dart';
import '../../features/drive/presentation/screens/folder_screen.dart';
import '../../features/drive/presentation/screens/file_details_screen.dart';
import '../../features/preview/presentation/screens/image_preview_screen.dart';
import '../../features/preview/presentation/screens/video_preview_screen.dart';
import '../../features/preview/presentation/screens/audio_preview_screen.dart';
import '../../features/preview/presentation/screens/pdf_preview_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../services/storage/secure_storage_service.dart';

// Route names
class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String verifyCode = '/verify-code';
  static const String verifyPassword = '/verify-password';
  static const String drive = '/drive';
  static const String folder = '/folder/:folderId';
  static const String fileDetails = '/file/:fileId';
  static const String previewImage = '/preview/image/:fileId';
  static const String previewVideo = '/preview/video/:fileId';
  static const String previewAudio = '/preview/audio/:fileId';
  static const String previewPdf = '/preview/pdf/:fileId';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String privacyPolicy = '/settings/privacy-policy';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.welcome,
    redirect: (context, state) async {
      final isLoggedIn = await SecureStorageService.instance.isLoggedIn();
      final isOnAuth = state.matchedLocation == AppRoutes.welcome ||
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.verifyCode ||
          state.matchedLocation == AppRoutes.verifyPassword;

      if (isLoggedIn && isOnAuth) {
        // Restore the TDLib session so the native client is live
        final authRepo = ref.read(authRepositoryProvider);
        await authRepo.restoreSession();
        return AppRoutes.drive;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginCredentialsScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyCode,
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return CodeVerificationScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.verifyPassword,
        builder: (context, state) => const PasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.drive,
        builder: (context, state) => const DriveHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.folder,
        builder: (context, state) {
          final folderId = state.pathParameters['folderId']!;
          final folderName = state.uri.queryParameters['name'] ?? 'Folder';
          return FolderScreen(folderId: folderId, folderName: folderName);
        },
      ),
      GoRoute(
        path: AppRoutes.fileDetails,
        builder: (context, state) {
          final fileId = state.pathParameters['fileId']!;
          return FileDetailsScreen(fileId: fileId);
        },
      ),
      GoRoute(
        path: AppRoutes.previewImage,
        builder: (context, state) {
          final fileId = state.pathParameters['fileId']!;
          return ImagePreviewScreen(fileId: fileId);
        },
      ),
      GoRoute(
        path: AppRoutes.previewVideo,
        builder: (context, state) {
          final fileId = state.pathParameters['fileId']!;
          return VideoPreviewScreen(fileId: fileId);
        },
      ),
      GoRoute(
        path: AppRoutes.previewAudio,
        builder: (context, state) {
          final fileId = state.pathParameters['fileId']!;
          return AudioPreviewScreen(fileId: fileId);
        },
      ),
      GoRoute(
        path: AppRoutes.previewPdf,
        builder: (context, state) {
          final fileId = state.pathParameters['fileId']!;
          return PdfPreviewScreen(fileId: fileId);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
