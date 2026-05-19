import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class FCMService {
  // Service Account JSON ported from LIME
  static const Map<String, dynamic> _serviceAccountJson = {
    "type": "service_account",
    "project_id": "limeapp-34c6f",
    "private_key_id": "47590b6fa1d20ed15e075fb9fc1f23c5713a41f8",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDIpMGRAlTEoBl1\nnr7Pe5V0KBent3HHlIEsRwpAF7WiemNEAOAnm1ohKk4TNLjMBWUWF8Z/mpxAa4ow\n7RC2kfX24Sw+60wxZY3Oz5NlfrvRhm4ntVYXxxmeGeL5ZLaxXu5dVfXTbz/+ba6U\nU2gjkNNnLAnQ31Dvlj686IPyqCTh+y6so7EC/hL1QXCeLeuEhlLblbqJmpgz7khH\nsiRcF39bQ8Y3n69w9g25kydBoAcTN9r/9U739bqsb11eONeKSIOGZycyl6KMs1Sd\nktAHt1/9JcQfJnK0OqSI5zASwNyhzUuutb+gAJXiMW3ORGthw60PrRuReI1VEFfw\n9lEj3BgtAgMBAAECggEAPs/ZKxC8QcvO/JPkLycErBbrBN24WF8EqzxYGKVzfrhq\nv/y4L54CMrTAOWH9Yh1kPmzV/teDh+VCnztvyn/aLN3kEJRvx1z/7ljsT09D8/1u\nGa86kvoI6oY3GJTvXoqV+5EwAm9m7Lsgdp2/0baCf994+TMX7tEttczilcIOvdFq\n5VXTVu9kvgqCpz2ezGV0QbcwxoCM9Xe1PZ9yYZls5CsaJqEMpCOtU+0cP4oNTlOl\nSBDJOsITs1RschWW65UZ3xQt73tguVu212bJ8DVYksvGV6xuU8dXsKSmvcWBAuaD\nZvgE5mtdNAGMmmjroJxr88StRCE9DAL/7eLNUSdNbwKBgQDxbqqHtQfsX32fswIL\n4L9SEURVpGfhdI0D2JAfziYv6hFV2pyJ9O/YkKcVNfxBJwCQ/mhBMho3vZqgmsBG\nRIvnTW2zG8+0osMsxgNCcSOTea0B6Uz+8Sel4LfvsMYyFFypUP0eUCQNCGjIKR8N\nX6GIt/pBveKE1EiGNmh8ccjSxwKBgQDUwAnpGmtSKH52VuUMoMxaqMWrEvZj/q10\nNRPnx7kqsBD5zymf3S9CiOOu6f1diqDEvBSInatERuqNIS2zamicS5DO/MrIwImk\nX/jmCW58oqlp9+ANjD0R9dK8j/gZOA3po6j44Bt6JBxT6pDRqhCQ9YjTSmMEA6DF\nVWANu2UJawKBgA6YfCK8JQB7PWL8NXF2YtqZRKJQ0B7nJudGnl/t3I0k/2tLTg9h\\CWb0R8WWf+uIahZZ6v+WAdPA2KpA8MLOvg577tdgQJFxtQpNgXS4VHOt7faQR8J+x\\AI6cqUIKU9EPPhLWXJcKjUNkcME5CzGJyIA1byGuUxVoqAHFJEfxsQxdAoGBAJUT\nI16lVoIxQbvmU4Uvv0HfdPLUzLVwpVYCQ3psJoGU8bA5yy7rq8vxY6kS6Kh9FP4F\n1FWONY4YKw5NK1rGuxqZkJSZafaVg10cqql1/mdzC0bnm6WimMBXAh2CvBPfxU/r\nj+EkF9zUJM1gVa20fvs0MXXsb8lGSYc8tZuprbiVAoGBALSGrV2DjwgU8OFEj/pd\nlbveG9KfhVKIAoO6F/q4kEe+yLBBoG8GX3aAi3z5gnaOS69elgsJRWTPNhReHflJ\nETaZg+lFzYTr/X/uCh0qwEWW5jitVMXFOM9JRtkbmTvJuRcftCOTVQHb7iw6OQX5\ndUpm5W5iw3/bCUa/ys67p9BI\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-fbsvc@limeapp-34c6f.iam.gserviceaccount.com",
    "client_id": "102468765442754350802",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40limeapp-34c6f.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  };

  /// Get Access Token using Service Account (for HTTP v1)
  static Future<String?> _getAccessToken() async {
    try {
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(_serviceAccountJson),
        scopes,
      );
      return client.credentials.accessToken.data;
    } catch (e) {
      debugPrint('FCM: Error getting access token: $e');
      return null;
    }
  }

  /// Sends a notification to a specific user (HTTP v1)
  static Future<void> sendNotification({
    required String recipientUid,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // 1. Write to Firestore 'notifications' for real-time foreground popups in LIME
      await FirebaseFirestore.instance.collection('notifications').add({
        'to': recipientUid,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      // 2. Try to send Background Push Notification
      final doc = await FirebaseFirestore.instance.collection('users').doc(recipientUid).get();
      final token = doc.data()?['deviceToken'] as String?;

      if (token == null) {
        debugPrint('FCM: No device token found for recipient $recipientUid');
        return;
      }

      final accessToken = await _getAccessToken();
      if (accessToken == null) return;

      final projectId = _serviceAccountJson['project_id'];
      final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': data ?? {},
            'android': {
              'priority': 'high',
              'notification': {
                'channel_id': 'high_importance_channel',
              },
            },
          }
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM: Background push sent successfully');
      } else {
        debugPrint('FCM: Error sending background push: ${response.body}');
      }
    } catch (e) {
      debugPrint('FCM: Error in sendNotification: $e');
    }
  }
}
