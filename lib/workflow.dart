import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'model.dart';
import 'fields.dart';
import 'ui.dart';

String normalizeNumber(String s){const ar='٠١٢٣٤٥٦٧٨٩',fa='۰۱۲۳۴۵۶۷۸۹';for(var i=0;i<10;i++){s=s.replaceAll(ar[i],'$i').replaceAll(fa[i],'$i');}return s.replaceAll('٫','.').replaceAll('٬','').replaceAll(',','').trim();}
double? parseNum(String s)=>double.tryParse(normalizeNumber(s));
class DataPage extends StatefulWidget{
  final DemoState state; final FormSpec spec;
  const DataPage(this.state,this.spec,{super.key});
  @override State<DataPage> createState()=>_DataPageState();
}
class _DataPageState extends State<DataPage>{
  final form=GlobalKey<FormState>();
  DemoState get state=>widget.state; FormSpec get spec=>widget.spec;
  void save(){if(form.currentState!.validate()){state.mark(spec.route);}else{state.completed.remove(spec.route);state.refresh();}}
  void next(){if(!form.currentState!.validate())return;state.mark(spec.route);go(context,spec.next);}
  @override Widget build(BuildContext context)=>PageFrame(title:spec.title,body:PageList([
    StepHeader(spec.route),Heading(spec.title,spec.subtitle),Panel(child:Form(key:form,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[for(final f in spec.fields) Padding(padding:const EdgeInsets.only(bottom:14),child:field(f))]))),
    if(spec.route=='/cash') Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('صافي التدفقات (حساب توضيحي)',style:TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:6),Text(((parseNum(state.value('cash.in'))??0)-(parseNum(state.value('cash.out'))??0)).toStringAsFixed(2),style:const TextStyle(fontSize:25,color:navy,fontWeight:FontWeight.bold)),const Text('الداخلة ناقص الخارجة؛ ليس تقييماً مصرفياً.')])),
    StepActions(next:spec.next,onSave:save,onNext:next)]));
  Widget field(FieldSpec f){final initial=state.value(f.key);final label=f.label+(f.required?' *':'');
    if(f.options.isNotEmpty){return DropdownButtonFormField<String>(value:f.options.contains(initial)?initial:null,isExpanded:true,decoration:InputDecoration(labelText:label),items:[for(final v in f.options) DropdownMenuItem(value:v,child:Text(v))],onChanged:(v)=>state.setValue(f.key,v??''),validator:(v)=>f.required&&(v==null||v.isEmpty)?'هذا الحقل مطلوب':null);}
    return TextFormField(initialValue:initial,maxLines:f.multiline?3:1,keyboardType:f.numeric?const TextInputType.numberWithOptions(decimal:true):f.multiline?TextInputType.multiline:TextInputType.text,decoration:InputDecoration(labelText:label,alignLabelWithHint:f.multiline),onChanged:(v){state.setValue(f.key,v);if(spec.route=='/cash')setState((){});},validator:(v){final s=(v??'').trim();if(f.required&&s.isEmpty)return 'هذا الحقل مطلوب';if(f.numeric&&s.isNotEmpty){final n=parseNum(s);if(n==null||!n.isFinite||n<0||(f.key=='financial.amount'&&n<=0))return 'أدخل رقماً صالحاً${f.key=='financial.amount'?' أكبر من صفر':''}';}return null;});
  }
}
class LocationPage extends StatefulWidget{
  final DemoState state;const LocationPage(this.state,{super.key});
  @override State<LocationPage> createState()=>_LocationPageState();
}
class _LocationPageState extends State<LocationPage>{
  final map=MapController();final lat=TextEditingController(),lng=TextEditingController();bool busy=false;bool mapReady=false;
  LatLng? point;
  @override void initState(){super.initState();point=widget.state.location;if(point!=null){lat.text=point!.latitude.toStringAsFixed(6);lng.text=point!.longitude.toStringAsFixed(6);}}
  @override void dispose(){map.dispose();lat.dispose();lng.dispose();super.dispose();}
  void select(LatLng p,{bool move=false}){setState((){point=p;lat.text=p.latitude.toStringAsFixed(6);lng.text=p.longitude.toStringAsFixed(6);widget.state.location=p;});if(move&&mapReady)map.move(p,15);}
  void manual(){final a=parseNum(lat.text),b=parseNum(lng.text);if(a==null||b==null||!a.isFinite||!b.isFinite||a.abs()>85||b.abs()>180){message(context,'أدخل إحداثيات صالحة للخريطة');return;}select(LatLng(a,b),move:true);}
  Future<void> locate() async {setState(()=>busy=true);try{if(!await Geolocator.isLocationServiceEnabled())throw Exception('فعّل خدمة الموقع أولاً');var perm=await Geolocator.checkPermission();if(perm==LocationPermission.denied)perm=await Geolocator.requestPermission();if(perm==LocationPermission.denied||perm==LocationPermission.deniedForever)throw Exception('لم يتم منح إذن الموقع؛ يمكنك تحديده يدوياً.');final p=await Geolocator.getCurrentPosition(locationSettings:const LocationSettings(accuracy:LocationAccuracy.high,timeLimit:Duration(seconds:20)));if(mounted)select(LatLng(p.latitude,p.longitude),move:true);}catch(e){if(mounted)message(context,'تعذر تحديد الموقع: $e');}finally{if(mounted)setState(()=>busy=false);}}
  @override Widget build(BuildContext context)=>PageFrame(title:'الموقع الجغرافي',body:PageList([const StepHeader('/location'),const Heading('حدد موقع مشروعك','اضغط على الخريطة أو استخدم موقع جهازك أو الإحداثيات.'),const Info('تحتاج خريطة OpenStreetMap إلى الإنترنت. مركز الخريطة الابتدائي صنعاء للعرض فقط وليس موقعك.'),ClipRRect(borderRadius:BorderRadius.circular(17),child:SizedBox(height:340,child:Stack(children:[FlutterMap(mapController:map,options:MapOptions(initialCenter:point??const LatLng(15.3694,44.1910),initialZoom:point==null?12:15,onMapReady:(){mapReady=true;},onTap:(_,p)=>select(p)),children:[TileLayer(urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',userAgentPackageName:'com.tamweely.app',maxZoom:19),if(point!=null) MarkerLayer(markers:[Marker(point:point!,width:50,height:50,child:const Icon(Icons.location_on,color:Colors.red,size:44))])]),const Positioned(bottom:0,left:0,child:ColoredBox(color:Colors.white,child:Padding(padding:EdgeInsets.all(4),child:Text('© OpenStreetMap contributors',style:TextStyle(fontSize:10)))))]))),
    FilledButton.icon(onPressed:busy?null:locate,icon:busy?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)):const Icon(Icons.my_location),label:Text(busy?'جاري تحديد الموقع...':'استخدام موقعي الحالي GPS')),
    Panel(child:Column(children:[TextField(controller:lat,keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),decoration:const InputDecoration(labelText:'خط العرض')),const SizedBox(height:10),TextField(controller:lng,keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),decoration:const InputDecoration(labelText:'خط الطول')),const SizedBox(height:10),OutlinedButton(onPressed:manual,child:const Text('تثبيت الإحداثيات على الخريطة')),Text(point==null?'لم يتم تحديد موقع بعد':'تم تحديد نقطة المشروع',style:const TextStyle(color:muted)),const SizedBox(height:12),TextFormField(initialValue:widget.state.value('location.address'),onChanged:(v)=>widget.state.setValue('location.address',v),decoration:const InputDecoration(labelText:'العنوان التفصيلي / أقرب معلم'),maxLines:2)])),
    StepActions(next:'/admin',onSave:(){if(point!=null)widget.state.mark('/location');},onNext:(){if(point==null){message(context,'حدد نقطة موقع المشروع أولاً');return;}widget.state.mark('/location');go(context,'/admin');})]));
}
class ReviewPage extends StatelessWidget{
  final DemoState state;const ReviewPage(this.state,{super.key});
  @override Widget build(BuildContext context)=>ListenableBuilder(listenable:state,builder:(context,_)=>PageFrame(title:'مراجعة وإرسال الطلب',body:PageList([const StepHeader('/review'),const Heading('راجع بيانات طلبك','يمكنك تعديل أي قسم قبل الإرسال التجريبي.'),const Info('الإرسال محلي فقط؛ لا يمثل قبولاً أو رفضاً من بنك، ولا تُنتج هذه النسخة درجة تقييم ذكية.'),
    for(int i=0;i<11;i++) Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(stepTitles[i],style:const TextStyle(fontSize:17,fontWeight:FontWeight.bold))),TextButton.icon(onPressed:()=>go(context,steps[i]),icon:const Icon(Icons.edit_outlined,size:17),label:const Text('تعديل'))]),...details(steps[i]).map((x)=>Padding(padding:const EdgeInsets.only(bottom:5),child:Text(x,style:const TextStyle(color:muted))))])),
    FilledButton.icon(onPressed:() async {final amount=parseNum(state.value('financial.amount'));if(state.value('project.name').trim().isEmpty||state.value('financial.currency').isEmpty||amount==null||!amount.isFinite||amount<=0||state.location==null){message(context,'أكمل اسم المشروع والعملة ومبلغ التمويل وحدد الموقع أولاً.');return;}final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('تأكيد الإرسال التجريبي'),content:const Text('سيتم حفظ نسخة من الطلب داخل الجلسة فقط ومسح المسودة الحالية.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('تأكيد الإرسال'))]));if(yes==true&&context.mounted){state.submit();final nav=Navigator.of(context);nav.pushNamedAndRemoveUntil('/dashboard',(_)=>false);nav.pushNamed('/tracking');}},icon:const Icon(Icons.send_outlined),label:const Text('إرسال طلب التمويل')),
    OutlinedButton(onPressed:()=>home(context),child:const Text('حفظ المسودة والعودة'))])));
  List<String> details(String route){if(route=='/location')return [state.location==null?'لم يحدد الموقع':'${state.location!.latitude.toStringAsFixed(6)} ، ${state.location!.longitude.toStringAsFixed(6)}',if(state.value('location.address').isNotEmpty)state.value('location.address')];if(route=='/documents'||route=='/photos'){final a=route=='/documents'?state.documents:state.photos;return a.isEmpty?['لا توجد مرفقات']:[for(final f in a)f.name];}final f=forms.firstWhere((f)=>f.route==route);final data=[for(final field in f.fields)if(state.value(field.key).trim().isNotEmpty)'${field.label}: ${state.value(field.key)}'];return data.isEmpty?['لم تدخل بيانات']:data;}
}
