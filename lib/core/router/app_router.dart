import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/event_landing_screen.dart';
import '../../presentation/screens/viewer_match_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/admin_event_detail_screen.dart';
import '../../presentation/screens/admin/admin_scoring_screen.dart';

import '../../presentation/screens/legal/public_legal_screen.dart';

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterRefreshStream(AuthService.onAuthStateChange),
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = AuthService.currentProfile != null;
      final loc = state.matchedLocation;
      final isLoginRoute = loc == '/login';
      final isPublicLegalRoute = loc.startsWith('/privacy') ||
          loc.startsWith('/policy') ||
          loc.startsWith('/terms');

      // Allow public legal documents to be viewed without authentication
      if (isPublicLegalRoute) {
        return null;
      }

      // If not logged in, enforce authentication gate
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      // If logged in and visiting /login, proceed to home
      if (isLoggedIn && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: <RouteBase>[
      // Public Legal Documents (Privacy Policy & Terms of Service)
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (BuildContext context, GoRouterState state) {
          return const PublicLegalScreen(docType: LegalDocType.privacy);
        },
      ),
      GoRoute(
        path: '/privacy.html',
        name: 'privacyHtml',
        builder: (BuildContext context, GoRouterState state) {
          return const PublicLegalScreen(docType: LegalDocType.privacy);
        },
      ),
      GoRoute(
        path: '/policy',
        name: 'policy',
        builder: (BuildContext context, GoRouterState state) {
          return const PublicLegalScreen(docType: LegalDocType.privacy);
        },
      ),
      GoRoute(
        path: '/policy.html',
        name: 'policyHtml',
        builder: (BuildContext context, GoRouterState state) {
          return const PublicLegalScreen(docType: LegalDocType.privacy);
        },
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacyPolicy',
        builder: (BuildContext context, GoRouterState state) {
          return const PublicLegalScreen(docType: LegalDocType.privacy);
        },
      ),
      GoRoute(
        path: '/privacy-policy.html',
        name: 'privacyPolicyHtml',
        builder: (BuildContext context, GoRouterState state) {
          return const PublicLegalScreen(docType: LegalDocType.privacy);
        },
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (BuildContext context, GoRouterState state) {
          return const PublicLegalScreen(docType: LegalDocType.terms);
        },
      ),
      GoRoute(
        path: '/terms.html',
        name: 'termsHtml',
        builder: (BuildContext context, GoRouterState state) {
          return const PublicLegalScreen(docType: LegalDocType.terms);
        },
      ),
      GoRoute(
        path: '/terms-of-service',
        name: 'termsOfService',
        builder: (BuildContext context, GoRouterState state) {
          return const PublicLegalScreen(docType: LegalDocType.terms);
        },
      ),
      GoRoute(
        path: '/terms-of-service.html',
        name: 'termsOfServiceHtml',
        builder: (BuildContext context, GoRouterState state) {
          return const PublicLegalScreen(docType: LegalDocType.terms);
        },
      ),
      // Authentication Gate Screen
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      // Public / Home Feed Route
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      // Master shareable event URL: /event/:share_slug
      GoRoute(
        path: '/event/:share_slug',
        name: 'eventLanding',
        builder: (BuildContext context, GoRouterState state) {
          final shareSlug = state.pathParameters['share_slug'] ?? '';
          return EventLandingScreen(shareSlug: shareSlug);
        },
      ),
      // Direct Live Match Viewer URL: /match/:match_id
      GoRoute(
        path: '/match/:match_id',
        name: 'viewerMatch',
        builder: (BuildContext context, GoRouterState state) {
          final matchId = state.pathParameters['match_id'] ?? '';
          return ViewerMatchScreen(matchId: matchId);
        },
      ),
      // Plural alias for match viewer: /matches/:match_id
      GoRoute(
        path: '/matches/:match_id',
        name: 'viewerMatches',
        builder: (BuildContext context, GoRouterState state) {
          final matchId = state.pathParameters['match_id'] ?? '';
          return ViewerMatchScreen(matchId: matchId);
        },
      ),

      // Admin & Scorer Console Routes
      GoRoute(
        path: '/admin',
        name: 'adminDashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const AdminDashboardScreen();
        },
        routes: <RouteBase>[
          // Event Sports & Fixtures Management: /admin/events/:event_id
          GoRoute(
            path: 'events/:event_id',
            name: 'adminEventDetail',
            builder: (BuildContext context, GoRouterState state) {
              final eventId = state.pathParameters['event_id'] ?? '';
              return AdminEventDetailScreen(eventId: eventId);
            },
          ),
          // Scorer Live Scorepad Controller: /admin/matches/:match_id/score
          GoRoute(
            path: 'matches/:match_id/score',
            name: 'adminScoring',
            builder: (BuildContext context, GoRouterState state) {
              final matchId = state.pathParameters['match_id'] ?? '';
              return AdminScoringScreen(matchId: matchId);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
