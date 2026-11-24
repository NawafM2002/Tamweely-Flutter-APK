import 'package:flutter/material.dart';
import 'model.dart';
import 'fields.dart';
const navy = Color(0xFF11243A);
const gold = Color(0xFFC59B49);
const paper = Color(0xFFF4F6F9);
const muted = Color(0xFF59677A);

// The original graduation-project artwork stays behind every main screen.
// The dark scrim and light panels preserve contrast without hiding the artwork.
class ProjectBackground extends StatelessWidget {
  final Widget child;
  final bool auth;
  const ProjectBackground({super.key, required this.child, this.auth = false});
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const ColoredBox(color: Color(0xFF0A1422)),
      const Positioned.fill(child: Image(
        key: ValueKey('project-background-artwork'),
        image: AssetImage('assets/images/logo.jpg'),
        fit: BoxFit.contain,
        alignment: Alignment.center,
        excludeFromSemantics: true,
      )),
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [const Color(0xFF081321).withOpacity(0.56),
            const Color(0xFF081321).withOpacity(auth ? 0.30 : 0.42),
            const Color(0xFF081321).withOpacity(0.66)],
        ),
      ))),
      child,
    ],
  );
}

void go(BuildContext context, String route) => Navigator.pushNamed(context, route);
void home(BuildContext context) => Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
void message(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
String dateLabel(DateTime d) => '${d.year}/${d.month.toString().padLeft(2,'0')}/${d.day.toString().padLeft(2,'0')}';
class Panel extends StatelessWidget {
  final Widget child;
  const Panel({super.key, required this.child});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(0.94), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE3E8EE))), child: child);
}
class PageFrame extends StatelessWidget {
  final String title;
  final Widget body;
  final bool dashboard;
  final Widget? action;
  const PageFrame({super.key, required this.title, required this.body, this.dashboard = false, this.action});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), actions: [if (!dashboard) IconButton(tooltip:'لوحة التحكم',onPressed:()=>home(context),icon:const Icon(Icons.home_outlined)), if(action!=null) action!]),
    body: ProjectBackground(child: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 850), child: SizedBox.expand(child: body))))));
}
class PageList extends StatelessWidget {
  final List<Widget> children;
  const PageList(this.children, {super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 20, 18, 30), children: [for(final w in children) Padding(padding: const EdgeInsets.only(bottom: 14), child:w)]);
}
class Heading extends StatelessWidget {
  final String title, subtitle;
  final bool onLight;
  const Heading(this.title,this.subtitle,{super.key,this.onLight=false});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text(title,style:TextStyle(fontSize:24,fontWeight:FontWeight.w800,color:onLight?navy:gold)), const SizedBox(height:6),Text(subtitle,style:TextStyle(color:onLight?muted:Colors.white,height:1.6))]);
}
class StepHeader extends StatelessWidget {
  final String route;
  const StepHeader(this.route,{super.key});
  @override Widget build(BuildContext context) {final i=steps.indexOf(route);return Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('الخطوة ${i+1} من ${steps.length} • طلب التمويل',style:const TextStyle(color:muted)),const SizedBox(height:10),LinearProgressIndicator(value:(i+1)/steps.length,backgroundColor:paper,color:gold,minHeight:7)]));}
}
class StepActions extends StatelessWidget {
  final String next;
  final VoidCallback onSave;
  final VoidCallback? onNext;
  const StepActions({super.key,required this.next,required this.onSave,this.onNext});
  @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[FilledButton.icon(onPressed:onNext??(){onSave();go(context,next);},icon:const Icon(Icons.arrow_forward),label:const Text('حفظ ومتابعة')),const SizedBox(height:8),OutlinedButton(onPressed:(){onSave();home(context);},child:const Text('حفظ مؤقت والعودة للوحة التحكم'))]);
}
class Info extends StatelessWidget {
  final String text;
  const Info(this.text,{super.key});
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xFFFFF5E0),borderRadius:BorderRadius.circular(12)),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.info_outline,color:navy,size:21),const SizedBox(width:9),Expanded(child:Text(text,style:const TextStyle(color:navy,height:1.5)))]));
}
class Dashboard extends StatelessWidget {
  final DemoState state;
  const Dashboard(this.state,{super.key});
  @override Widget build(BuildContext context)=>ListenableBuilder(listenable:state,builder:(context,_)=>PageFrame(title:'تمويلي | لوحة التحكم',dashboard:true,action:IconButton(tooltip:'تسجيل الخروج',icon:const Icon(Icons.logout),onPressed:() async {final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('تسجيل الخروج'),content:const Text('ستُحذف بيانات الجلسة التجريبية. هل تريد المتابعة؟'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('خروج'))]));if(yes==true&&context.mounted){state.signOut();Navigator.pushNamedAndRemoveUntil(context,'/login',(_)=>false);}}),body:PageList([
    Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:navy.withOpacity(0.92),borderRadius:BorderRadius.circular(22),border:Border.all(color:gold.withOpacity(0.55))),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('أهلاً بك في تمويلي',style:TextStyle(color:gold,fontSize:14)),const SizedBox(height:7),Text(state.name.isEmpty?'طالب التمويل':state.name,style:const TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('نقيّم اليوم… لنموّل نجاح الغد',style:TextStyle(color:Colors.white70))])),ClipRRect(borderRadius:BorderRadius.circular(13),child:Image.asset('assets/images/logo.jpg',width:90,height:90,fit:BoxFit.cover))])),
    const Info('نسخة عرض جامعية • لا تُرسل البيانات إلى بنك ولا تُحسب نتيجة تقييم حقيقية.'),
    Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const Text('طلب التمويل الحالي',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),const SizedBox(height:10),Text('${state.completed.length} / 11 أقسام تم حفظها'),const SizedBox(height:8),LinearProgressIndicator(value:state.completed.length.clamp(0,11)/11,color:gold),const SizedBox(height:14),FilledButton.icon(onPressed:(){final pending=steps.take(11).where((s)=>!state.completed.contains(s));go(context,pending.isEmpty?'/review':pending.first);},icon:const Icon(Icons.add_circle_outline),label:Text(state.data.isEmpty&&state.completed.isEmpty?'إنشاء طلب تمويل':'متابعة المسودة'))])),
    const Heading('الخدمات','تنقّل بين خدمات حسابك.'),
    Wrap(spacing:10,runSpacing:10,children:[_shortcut(context,Icons.person_outline,'الملف الشخصي','/profile'),_shortcut(context,Icons.assignment_outlined,'طلباتي (${state.requests.length})','/tracking'),_shortcut(context,Icons.notifications_outlined,'الإشعارات (${state.unread})','/notifications'),_shortcut(context,Icons.support_agent,'الدعم والتظلمات','/support')]),
    const Heading('أقسام الطلب','يمكن فتح أي قسم مباشرة.'),
    Panel(child:Column(children:[for(int i=0;i<steps.length;i++) ListTile(contentPadding:EdgeInsets.zero,leading:CircleAvatar(backgroundColor:paper,foregroundColor:navy,child:state.completed.contains(steps[i])?const Icon(Icons.check,color:Colors.green):Text('${i+1}')),title:Text(stepTitles[i]),trailing:const Icon(Icons.chevron_right),onTap:()=>go(context,steps[i]))])),
  ])));
  Widget _shortcut(BuildContext context,IconData icon,String label,String route)=>SizedBox(width:150,child:Material(color:Colors.white.withOpacity(0.94),borderRadius:BorderRadius.circular(14),child:InkWell(borderRadius:BorderRadius.circular(14),onTap:()=>go(context,route),child:Padding(padding:const EdgeInsets.all(14),child:Column(children:[Icon(icon,color:navy,size:29),const SizedBox(height:8),Text(label,textAlign:TextAlign.center)])))));
}
