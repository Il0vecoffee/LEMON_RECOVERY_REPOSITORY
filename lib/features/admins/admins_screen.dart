import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/admin.dart';
import '../../models/invitation.dart';
import '../../services/admin_service.dart';

class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key});

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lemonBackground,
      appBar: AppBar(
        title: const Text('Administrator Management'),
        backgroundColor: AppTheme.lemonHeader,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        actions: [
          StreamBuilder<List<dynamic>>(
            stream: _getCombinedStream(),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    '$count / 5 Slots Used',
                    style: TextStyle(
                      color: count >= 5 ? AppTheme.errorRed : Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send_outlined, size: 18),
            label: const Text('Invite Admin'),
            onPressed: () => _handleInvite(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lemonHeader,
              foregroundColor: AppTheme.white,
              elevation: 0,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _getCombinedStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          // Sort items by creation date
          items.sort((a, b) {
            final aTime = a is Admin ? a.createdAt : (a as AdminInvitation).createdAt;
            final bTime = b is Admin ? b.createdAt : (b as AdminInvitation).createdAt;
            return aTime.compareTo(bTime);
          });

          if (items.isEmpty) {
            return const Center(child: Text('No administrators or invitations yet.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(32),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              mainAxisExtent: 140,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildCombinedNode(items[index]),
          );
        },
      ),
    );
  }

  Stream<List<dynamic>> _getCombinedStream() {
    return _adminService.getAdmins().asyncMap((admins) async {
      final invitations = await _adminService.getInvitations().first;
      return [...admins, ...invitations];
    });
  }

  Widget _buildCombinedNode(dynamic item) {
    if (item is Admin) {
      return _buildAdminNode(item);
    } else {
      return _buildInvitationNode(item as AdminInvitation);
    }
  }

  Widget _buildAdminNode(Admin admin) {
    return _buildCardWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            admin.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppTheme.lemonText, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            admin.email,
            style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
          ),
        ],
      ),
      icon: Icons.person,
      color: AppTheme.primaryLemon,
      onDelete: () => _handleDelete(admin),
    );
  }

  Widget _buildInvitationNode(AdminInvitation invite) {
    return _buildCardWrapper(
      isPending: true,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Icon(Icons.link, color: Colors.blueAccent, size: 28),
          SizedBox(height: 8),
          Text(
            'ACTIVE INVITATION LINK',
            style: TextStyle(fontSize: 10, color: Colors.blueAccent, letterSpacing: 1, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text('Slot is reserved', style: TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
      icon: Icons.hourglass_empty,
      color: AppTheme.lemonHeader.withValues(alpha: 0.6),
      onDelete: () => _handleDeleteInvite(invite),
      onShowLink: () => _showInviteLink(invite.token),
    );
  }

  Widget _buildCardWrapper({
    required Widget child,
    required IconData icon,
    required Color color,
    required VoidCallback onDelete,
    VoidCallback? onShowLink,
    bool isPending = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color: AppTheme.lemonCard,
              border: Border.all(color: color.withValues(alpha: isPending ? 0.3 : 1), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: isPending ? 0.2 : 1), width: 2),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        Positioned(
          right: 0,
          top: 20,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onShowLink != null)
                IconButton(
                  icon: const Icon(Icons.link, size: 18, color: Colors.blue),
                  onPressed: onShowLink,
                  tooltip: 'Show Link',
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                onPressed: onDelete,
                tooltip: isPending ? 'Cancel Invitation' : 'Remove Admin',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleInvite() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Administrator Invitation'),
        content: const Text('This will generate a unique link. Anyone with this link can set up an administrator account on this portal.\n\nContinue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate Link'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final token = await _adminService.createInvitation();
        if (mounted) {
          _showInviteLink(token);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _showInviteLink(String token) {
    String baseUrl;
    try {
      baseUrl = Uri.base.origin;
    } catch (e) {
      // Fallback for non-web environments or file:// schemes
      baseUrl = 'https://your-lemon-portal.com';
    }
    
    final inviteLink = '$baseUrl/#/admin-setup/$token';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invitation Link Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Share this link with the new administrator. They can use it to set up their account.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  SelectableText(inviteLink, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                  if (inviteLink.contains('your-lemon-portal.com')) 
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Note: Replace the domain above with your local test URL (e.g., localhost:XXXX) if testing locally.',
                        style: TextStyle(fontSize: 10, color: Colors.orange, fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy Token Only'),
              onPressed: () {
                // In a real app we would use Clipboard.setData
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Token copied: $token')));
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _handleDelete(Admin admin) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Administrator'),
        content: Text('Are you sure you want to remove ${admin.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _adminService.deleteAdmin(admin.uid);
    }
  }

  Future<void> _handleDeleteInvite(AdminInvitation invite) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Invitation'),
        content: const Text('Are you sure you want to cancel this invitation?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Back')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Cancel Invite'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _adminService.deleteInvitation(invite.token);
    }
  }
}
