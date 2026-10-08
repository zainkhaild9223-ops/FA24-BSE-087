import 'package:flutter/material.dart';
import 'theme.dart';

class Card2 extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color, bar;
  final VoidCallback? onTap;
  const Card2({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color, this.bar, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget body = Padding(padding: padding, child: child);
    if (bar != null) {
      body = IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 4, color: bar),
          Expanded(child: body),
        ]),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x120B1C30), blurRadius: 12, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, child: body)),
    );
  }
}

class Pill extends StatelessWidget {
  final String t;
  final Color bg, fg;
  final IconData? icon;
  const Pill(this.t, this.bg, this.fg, {super.key, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
          Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
        ]),
      );
}

class Meta extends StatelessWidget {
  final String t;
  const Meta(this.t, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(20)),
        child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  final double size;
  const IconBadge(this.icon, this.bg, this.fg, this.size, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: size * 0.5, color: fg),
      );
}

// Replace with Image.asset / NetworkImage when you have real photos.
class Avatar extends StatelessWidget {
  final String name;
  final double r;
  const Avatar(this.name, this.r, {super.key});
  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: r,
        backgroundColor: C.blueChip,
        child: Text(name[0], style: TextStyle(color: C.primary, fontWeight: FontWeight.w700, fontSize: r * 0.8)),
      );
}

class Btn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool filled;
  const Btn(this.label, {super.key, this.icon, this.onTap, this.filled = true});
  @override
  Widget build(BuildContext context) {
    final st = ElevatedButton.styleFrom(
      backgroundColor: filled ? C.primary : C.lav2,
      foregroundColor: filled ? Colors.white : C.primary,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    );
    final cb = onTap ?? () {};
    return SizedBox(
      width: double.infinity, height: 52,
      child: icon == null
          ? ElevatedButton(style: st, onPressed: cb, child: Text(label))
          : ElevatedButton.icon(style: st, onPressed: cb, icon: Icon(icon, size: 20), label: Text(label)),
    );
  }
}

class H extends StatelessWidget {
  final String t;
  const H(this.t, {super.key});
  @override
  Widget build(BuildContext context) => Text(t, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700));
}

PreferredSizeWidget topBar(BuildContext c, String title, String sub) => AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(c)),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        Text(sub, style: const TextStyle(fontSize: 11, color: C.primary, fontWeight: FontWeight.w600)),
      ]),
      actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Avatar('Sarah', 16))],
    );
