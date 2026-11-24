import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'model.dart';
import 'ui.dart';

class AttachmentPage extends StatefulWidget{
  final DemoState state;final bool photos;
  const AttachmentPage(this.state,{super.key,required this.photos});
  @override State<AttachmentPage> createState()=>_AttachmentPageState();
}
class _AttachmentPageState extends State<AttachmentPage>{
  bool busy=false;String category='هوية صاحب المشروع';
  List<Attachment> get items=>widget.photos?widget.state.photos:widget.state.documents;
  static const maxBytes=15*1024*1024;
  void add(Attachment a){if(a.bytes.isEmpty||a.bytes.length>maxBytes){message(context,'تعذر إضافة ${a.name}: الملف فارغ أو أكبر من 15 ميغابايت');return;}if(items.length>=20){message(context,'الحد التجريبي 20 مرفقاً لكل قسم');return;}if(items.any((x)=>x.name==a.name&&x.bytes.length==a.bytes.length)){message(context,'المرفق موجود مسبقاً');return;}setState(()=>items.add(a));widget.state.refresh();}
  Future<void> pickFiles() async {setState(()=>busy=true);try{final r=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['pdf','jpg','jpeg','png','txt'],allowMultiple:true,withData:true);if(r!=null&&mounted){for(final f in r.files){if(f.bytes==null){message(context,'تعذر قراءة ${f.name}');continue;}add(Attachment(f.name,category,f.bytes!));}}}catch(e){if(mounted)message(context,'تعذر اختيار المستندات: $e');}finally{if(mounted)setState(()=>busy=false);}}
  Future<void> pickImage(bool camera) async {setState(()=>busy=true);try{final picker=ImagePicker();final files=<XFile>[];if(camera){final f=await picker.pickImage(source:ImageSource.camera,imageQuality:85,maxWidth:1800);if(f!=null)files.add(f);}else{files.addAll(await picker.pickMultiImage(imageQuality:85,maxWidth:1800));}for(final f in files){final bytes=await f.readAsBytes();if(!mounted)return;add(Attachment(f.name,'صورة المشروع',bytes));}}catch(e){if(mounted)message(context,'تعذر الوصول إلى الصور أو الكاميرا: $e');}finally{if(mounted)setState(()=>busy=false);}}
  Future<void> remove(Attachment a) async {final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('حذف المرفق؟'),content:Text(a.name),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('حذف'))]));if(yes==true&&mounted){setState(()=>items.remove(a));widget.state.refresh();}}
  @override Widget build(BuildContext context){final photos=widget.photos;return PageFrame(title:photos?'صور المشروع':'المستندات',body:PageList([StepHeader(photos?'/photos':'/documents'),Heading(photos?'أضف صور مشروعك':'أرفق مستنداتك',photos?'التقط صورة أو اختر صوراً من المعرض.':'اختر نوع المستند ثم الملفات من جهازك.'),const Info('المرفقات تبقى في ذاكرة الجلسة فقط. الحد التقني التجريبي 15 MB لكل ملف و20 مرفقاً لكل قسم؛ لا يمثل شرطاً بنكياً.'),
    if(!photos) Panel(child:DropdownButtonFormField<String>(value:category,decoration:const InputDecoration(labelText:'نوع المستند'),isExpanded:true,items:[for(final c in ['هوية صاحب المشروع','السجل التجاري','قوائم مالية','دراسة الجدوى','مستند ضمان','مستند آخر']) DropdownMenuItem(value:c,child:Text(c))],onChanged:busy?null:(v)=>setState(()=>category=v!))),
    if(photos)...[FilledButton.icon(onPressed:busy?null:()=>pickImage(true),icon:const Icon(Icons.camera_alt_outlined),label:const Text('التقاط صورة بالكاميرا')),OutlinedButton.icon(onPressed:busy?null:()=>pickImage(false),icon:const Icon(Icons.photo_library_outlined),label:const Text('اختيار من المعرض')),if(kIsWeb)const Info('على الويب قد يفتح المتصفح منتقي الصور بدلاً من الكاميرا؛ اختبر الكاميرا على هاتف Android.')]
    else FilledButton.icon(onPressed:busy?null:pickFiles,icon:const Icon(Icons.upload_file),label:const Text('اختيار PDF أو JPG أو PNG أو TXT')),
    if(busy)const LinearProgressIndicator(),Heading('المرفقات (${items.length})','اضغط على المرفق لمعاينته أو استخدم الحذف.'),
    if(items.isEmpty)const Panel(child:Column(children:[Icon(Icons.folder_open,size:48,color:muted),SizedBox(height:8),Text('لم تتم إضافة مرفقات بعد')])) else for(final a in items) Panel(child:ListTile(contentPadding:EdgeInsets.zero,leading:photos?ClipRRect(borderRadius:BorderRadius.circular(8),child:Image.memory(a.bytes,width:53,height:53,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const Icon(Icons.broken_image))):Icon(a.extension=='pdf'?Icons.picture_as_pdf:Icons.insert_drive_file_outlined,color:navy),title:Text(a.name,maxLines:2,overflow:TextOverflow.ellipsis),subtitle:Text('${a.category} • ${(a.bytes.length/1024).toStringAsFixed(1)} KB'),onTap:()=>showDialog<void>(context:context,builder:(_)=>PreviewDialog(a,forceImage:photos)),trailing:IconButton(tooltip:'حذف',onPressed:()=>remove(a),icon:const Icon(Icons.delete_outline,color:Colors.redAccent)))),
    StepActions(next:photos?'/review':'/photos',onSave:()=>widget.state.mark(photos?'/photos':'/documents'))]));}
}
class PreviewDialog extends StatefulWidget{
  final Attachment attachment;final bool forceImage;const PreviewDialog(this.attachment,{super.key,this.forceImage=false});
  @override State<PreviewDialog> createState()=>_PreviewDialogState();
}
class _PreviewDialogState extends State<PreviewDialog>{
  PdfControllerPinch? pdf;String? error;
  @override void initState(){super.initState();if(widget.attachment.extension=='pdf'&&!widget.forceImage){pdf=PdfControllerPinch(document:PdfDocument.openData(widget.attachment.bytes));}}
  @override void dispose(){pdf?.dispose();super.dispose();}
  @override Widget build(BuildContext context){final a=widget.attachment;return Dialog(child:SizedBox(width:700,height:MediaQuery.sizeOf(context).height*0.78,child:Column(children:[Padding(padding:const EdgeInsets.all(10),child:Row(children:[Expanded(child:Text(a.name,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.bold))),IconButton(tooltip:'إغلاق المعاينة',onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.close))])),const Divider(height:1),Expanded(child:error!=null?Center(child:Text(error!)):pdf!=null?PdfViewPinch(controller:pdf!,onDocumentError:(e){if(mounted)setState(()=>error='تعذرت معاينة PDF: $e');}):widget.forceImage||['jpg','jpeg','png'].contains(a.extension)?InteractiveViewer(child:Center(child:Image.memory(a.bytes,errorBuilder:(_,__,___)=>const Text('تعذرت قراءة الصورة')))):a.extension=='txt'?SingleChildScrollView(padding:const EdgeInsets.all(18),child:SelectableText(utf8.decode(a.bytes,allowMalformed:true))):const Center(child:Text('لا تتوفر معاينة لهذا النوع'))),const SizedBox(height:8)])));}
}
