import 'package:flutter/material.dart';

// === Your pages ===
import 'package:resq_frontend/pages/all_post_detail_page.dart';
import 'package:resq_frontend/pages/donation_list_page.dart';
import 'pages/disaster_guide_page.dart';
import 'pages/disastertype_filtering_page.dart';
import 'pages/donation_detail_page.dart';
import 'pages/donation_payment_page.dart';
import 'pages/region_category_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';
import 'pages/map_page.dart';
import 'pages/chatbot_page.dart';
import 'pages/community_page.dart';
import 'pages/user_page.dart';
import 'pages/allposts_page.dart';
import 'pages/writepost_page.dart';
import 'pages/hotposts_page.dart';
import 'pages/withdrawl_page.dart';
import 'pages/disaster_menu_page.dart';
import 'pages/password_reset_new_page.dart';
import 'pages/password_reset_request_page.dart';
import 'pages/password_reset_verify_page.dart';
import 'pages/initial_page.dart';
import 'pages/checklist.dart';
import 'pages/news_page.dart';
import 'pages/my_post_detail_page.dart';
import 'pages/all_disaster_type_detail_page.dart';
import 'pages/disaster_detail_page.dart';


/// Central place for route names
class AppRoutes {
  static const root = '/';
  static const initial = '/initial';
  static const login = '/login';
  static const signup = '/signup';
  static const map = '/map';
  static const chatbot = '/chatbot';
  static const community = '/community';
  static const user = '/user';
  static const allposts = '/allposts';
  static const hotposts = '/hotposts';
  static const createpost = '/createpost';
  static const withdrawl = '/withdrawl';
  static const disastermenu = '/disastermenu';
  static const fire = '/fire';
  static const landslide = '/landslide';
  static const flood = '/flood';
  static const typhoon = '/typhoon';
  static const earthquake = '/earthquake';
  static const coldwave = '/coldwave';
  static const regionFilter = '/region-filter';
  static const typeFilter = '/type-filter';
  static const disasterlist = '/disasterlist';
  static const checklist = '/checklist';
  static const news = '/news';
  static const myPostDetail = '/postDetail'; // (your existing name)
  static const donation = '/donation';
  static const donationDetail = '/detail';
  static const donationPayment = '/payment';
  static const allPostDetail = '/allpostdetail';
  static const allDisasters = '/all-disasters';
  static const disasterDetail = '/disasterDetail';


  // password reset
  static const pwReq = '/password_reset_request';
  static const pwVerify = '/password_reset_verify';
  static const pwNew = '/password_reset_new';
}

/// Safer router: handles args & unknown routes
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final name = settings.name ?? AppRoutes.login;
    final args = settings.arguments;

    switch (name) {
      case AppRoutes.root:
      case AppRoutes.initial:
        return _page(const InitialPage());

      case AppRoutes.login:
        return _page(LoginPage());

      case AppRoutes.signup:
        return _page(SignUpPage());

      case AppRoutes.map:
        return _page(MapPage());

      case AppRoutes.chatbot:
        return _page(ChatbotPage());

      case AppRoutes.community:
        return _page(CommunityMainPage());

      case AppRoutes.user:
        return _page(UserProfilePage());

      case AppRoutes.allposts:
        return _page(AllPostsPage());

      case AppRoutes.hotposts:
        return _page(HotPostsPage());

      case AppRoutes.createpost:
        return _page(PostCreatePage());

      case AppRoutes.withdrawl:
        return _page(WithdrawalConfirmationPage());

      case AppRoutes.disastermenu:
        return _page(DisasterMenuPage());

      case AppRoutes.fire:
        return _page(const DisasterGuidePage(initialIndex: 0));
      case AppRoutes.landslide:
        return _page(const DisasterGuidePage(initialIndex: 1));
      case AppRoutes.flood:
        return _page(const DisasterGuidePage(initialIndex: 2));
      case AppRoutes.typhoon:
        return _page(const DisasterGuidePage(initialIndex: 3));
      case AppRoutes.earthquake:
        return _page(const DisasterGuidePage(initialIndex: 4));
      case AppRoutes.coldwave:
        return _page(const DisasterGuidePage(initialIndex: 5));

      case AppRoutes.regionFilter:
        return _page(RegionCategoryPage());

      case AppRoutes.typeFilter:
        return _page(NotificationSettingsPage());

      case AppRoutes.disasterlist:
        return _page(const DisasterGuidePage(initialIndex: 0));

      case AppRoutes.checklist:
        return _page(const ChecklistPage());

      case AppRoutes.news:
        return _page(NewsPage());

      case AppRoutes.myPostDetail:
        return _page(const PostDetailPage());

      case AppRoutes.donation:
        return _page(DonationListPage());

      case AppRoutes.donationDetail:
        return _page(DonationDetailPage());

      case AppRoutes.donationPayment:
        return _page(DonationPaymentPage());

      case AppRoutes.allDisasters:
        return _page(const AllDisasterTypeDetailPage());

      case AppRoutes.allPostDetail:
        {
          // expects Map<String, dynamic> post
          final map = (args is Map<String, dynamic>) ? args : <String, dynamic>{};
          return _page(AllPostDetailPage(post: map));
        }

    // --- Password reset flow with null-safe args ---
      case AppRoutes.pwReq:
        return _page(const PasswordResetRequestPage());

      case AppRoutes.pwVerify:
        {
          // expects { "email": String }
          String email = '';
          if (args is Map && args['email'] is String) {
            email = args['email'] as String;
          }
          return _page(PasswordResetVerifyPage(email: email));
        }

      case AppRoutes.pwNew:
        {
          // expects { "email": String, "code": String }
          String email = '';
          String code = '';
          if (args is Map) {
            if (args['email'] is String) email = args['email'] as String;
            if (args['code'] is String) code = args['code'] as String;
          }
          return _page(PasswordResetNewPage(email: email, code: code));
        }

      case AppRoutes.disasterDetail: {
        final disaster = (args is Disaster) ? args : null;
        // If disaster is null, you can show an error page or a placeholder
        return _page(
          disaster != null
              ? DisasterDetailPage(disaster: disaster)
              : const Scaffold(
            body: Center(child: Text('잘못된 재난 정보입니다.')),
          ),
        );
      }


      default:
      // Fallback to login to avoid "Page not found"
        return _page(LoginPage());
    }
  }

  static MaterialPageRoute _page(Widget child) =>
      MaterialPageRoute(builder: (_) => child);
}
