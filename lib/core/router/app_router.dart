import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/event_landing_screen.dart';
import '../../presentation/screens/viewer_match_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/admin_event_detail_screen.dart';
import '../../presentation/screens/admin/admin_scoring_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      // Public / Viewer Routes
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
