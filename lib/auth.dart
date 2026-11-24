import 'package:flutter/material.dart';
import 'model.dart';
import 'ui.dart';
enum AuthKind {login, register, reset}
class AuthPage extends StatefulWidget {
  final DemoState state;
  final AuthKind kind;
  const AuthPage({super.key,required this.state,required this.kind});
  @override State<AuthPage> createState()=>_AuthPageState();
}
class _AuthPageState extends State<AuthPage>{
  final form=GlobalKey<FormState>();
  final name=TextEditingController(), email=TextEditingController(), phone=TextEditingController(), password=TextEditingController(), confirm=TextEditingController();
  bool hidden=true, accepted=false;
  bool get registering=>widget.kind==AuthKind.register;
  bool get resetting=>widget.kind==AuthKind.reset;
  @override void dispose(){for(final c in [name,email,phone,password,confirm]){c.dispose();}super.dispose();}
  void submit(){if(!form.currentState!.validate())return;if(registering&&!accepted){message(context,'يرجى الموافقة على استخدام بيانات تجريبية فقط.');return;}
    if(resetting){showDialog<void>(context:context,builder:(c)=>AlertDialog(title:const Text('استعادة كلمة المرور'),content:const Text('تم تسجيل طلب الاستعادة تجريبياً. لا يتم إرسال بريد إلكتروني في هذه النسخة.'),actions:[FilledButton(onPressed:()=>Navigator.pop(c),child:const Text('حسناً'))]));return;}
    widget.state.email=email.text.trim();widget.state.name=registering?name.text.trim():email.text.split('@').first;widget.state.phone=phone.text.trim();home(context);
  }
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:navy,body:ProjectBackground(auth:true,child:SafeArea(child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:490),child:ListView(shrinkWrap:true,padding:const EdgeInsets.all(22),children:[
    if(widget.kind!=AuthKind.login) Align(alignment:AlignmentDirectional.centerStart,child:IconButton(color:Colors.white,tooltip:'رجوع',onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.arrow_back))),
    Center(child:ClipRRect(borderRadius:BorderRadius.circular(20),child:Image.asset('assets/images/logo.jpg',width:180,height:180,fit:BoxFit.cover))),const SizedBox(height:12),
    const Text('تمويلي',textAlign:TextAlign.center,style:TextStyle(color:gold,fontSize:30,fontWeight:FontWeight.bold)),const Text('نظام التقييم الذكي للتمويل البنكي',textAlign:TextAlign.center,style:TextStyle(color:Colors.white70)),const SizedBox(height:22),
    Panel(child:Form(key:form,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Heading(registering?'إنشاء حساب':resetting?'استعادة كلمة المرور':'تسجيل الدخول',registering?'ابدأ رحلتك مع طلب التمويل.':resetting?'أدخل البريد لاستعراض آلية الاستعادة.':'ادخل إلى مساحة طالب التمويل.',onLight:true),const SizedBox(height:18),
      if(registering)...[TextFormField(controller:name,decoration:const InputDecoration(labelText:'الاسم الكامل',prefixIcon:Icon(Icons.person_outline)),validator:(v)=>v==null||v.trim().isEmpty?'أدخل الاسم':null),const SizedBox(height:12)],
      TextFormField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'البريد الإلكتروني',prefixIcon:Icon(Icons.email_outlined)),validator:(v)=>RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((v??'').trim())?null:'أدخل بريداً إلكترونياً صحيحاً'),const SizedBox(height:12),
      if(registering)...[TextFormField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'رقم الهاتف',prefixIcon:Icon(Icons.phone_outlined))),const SizedBox(height:12)],
      if(!resetting)...[TextFormField(controller:password,obscureText:hidden,decoration:InputDecoration(labelText:'كلمة المرور',prefixIcon:const Icon(Icons.lock_outline),suffixIcon:IconButton(tooltip:hidden?'إظهار':'إخفاء',onPressed:()=>setState(()=>hidden=!hidden),icon:Icon(hidden?Icons.visibility_outlined:Icons.visibility_off_outlined))),validator:(v)=>(v??'').length<6?'أدخل 6 أحرف على الأقل للعرض':null),const SizedBox(height:12)],
      if(registering)...[TextFormField(controller:confirm,obscureText:hidden,decoration:const InputDecoration(labelText:'تأكيد كلمة المرور'),validator:(v)=>v!=password.text?'كلمتا المرور غير متطابقتين':null),CheckboxListTile(contentPadding:EdgeInsets.zero,value:accepted,onChanged:(v)=>setState(()=>accepted=v??false),title:const Text('أوافق على إدخال بيانات تجريبية فقط'))],
      if(widget.kind==AuthKind.login) Align(alignment:AlignmentDirectional.centerEnd,child:TextButton(onPressed:()=>go(context,'/reset'),child:const Text('نسيت كلمة المرور؟'))),
      FilledButton(onPressed:submit,child:Text(registering?'إنشاء الحساب':resetting?'إرسال طلب الاستعادة':'دخول')),
      if(widget.kind==AuthKind.login)...[TextButton(onPressed:()=>go(context,'/register'),child:const Text('ليس لديك حساب؟ إنشاء حساب')),OutlinedButton(onPressed:(){widget.state.name='طالب التمويل التجريبي';widget.state.email='demo@example.com';home(context);},child:const Text('الدخول بحساب تجريبي'))],
      if(widget.kind!=AuthKind.login) TextButton(onPressed:()=>Navigator.pop(context),child:const Text('العودة لتسجيل الدخول')),
    ]))),const SizedBox(height:16),const Text('نموذج جامعي • لا توجد مصادقة حقيقية أو قاعدة بيانات',textAlign:TextAlign.center,style:TextStyle(color:Colors.white70,fontSize:12))]))))));
}
class ProfilePage extends StatefulWidget{
  final DemoState state;const ProfilePage(this.state,{super.key});
  @override State<ProfilePage> createState()=>_ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage>{
  final form=GlobalKey<FormState>();late final TextEditingController name,email,phone;
  @override void initState(){super.initState();name=TextEditingController(text:widget.state.name);email=TextEditingController(text:widget.state.email);phone=TextEditingController(text:widget.state.phone);}
  @override void dispose(){name.dispose();email.dispose();phone.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>PageFrame(title:'الملف الشخصي',body:PageList([const Heading('حساب طالب التمويل','تعديل المعلومات الشخصية خلال الجلسة.'),const Center(child:CircleAvatar(radius:43,backgroundColor:navy,foregroundColor:gold,child:Icon(Icons.person,size:48))),Panel(child:Form(key:form,child:Column(children:[TextFormField(controller:name,decoration:const InputDecoration(labelText:'الاسم الكامل'),validator:(v)=>(v??'').trim().isEmpty?'أدخل الاسم':null),const SizedBox(height:12),TextFormField(controller:email,decoration:const InputDecoration(labelText:'البريد الإلكتروني'),keyboardType:TextInputType.emailAddress,validator:(v)=>RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((v??'').trim())?null:'بريد غير صحيح'),const SizedBox(height:12),TextFormField(controller:phone,decoration:const InputDecoration(labelText:'رقم الهاتف'),keyboardType:TextInputType.phone)]))),FilledButton.icon(onPressed:(){if(form.currentState!.validate()){widget.state.name=name.text.trim();widget.state.email=email.text.trim();widget.state.phone=phone.text.trim();widget.state.refresh();message(context,'تم حفظ الملف الشخصي مؤقتاً');}},icon:const Icon(Icons.save_outlined),label:const Text('حفظ التعديلات'))]));
}
