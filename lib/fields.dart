class FieldSpec {
  final String key, label;
  final bool required, numeric, multiline;
  final List<String> options;
  const FieldSpec(this.key, this.label, {this.required = false, this.numeric = false, this.multiline = false, this.options = const []});
}
class FormSpec {
  final String route, title, subtitle, next;
  final List<FieldSpec> fields;
  const FormSpec(this.route, this.title, this.subtitle, this.next, this.fields);
}
const forms = <FormSpec>[
  FormSpec('/project', 'بيانات المشروع', 'عرّفنا بمشروعك ونشاطه الأساسي.', '/location', [
    FieldSpec('project.name','اسم المشروع',required:true), FieldSpec('project.sector','القطاع',options:['تجاري','صناعي','خدمي','زراعي','تقني','أخرى']), FieldSpec('project.type','حالة المشروع',options:['قائم','جديد','قيد التأسيس']), FieldSpec('project.legal','الشكل القانوني'), FieldSpec('project.year','سنة التأسيس',numeric:true), FieldSpec('project.description','وصف المشروع',multiline:true)]),
  FormSpec('/admin', 'البيانات الإدارية', 'فريق الإدارة والملكية والخبرة.', '/operations', [
    FieldSpec('admin.owner','اسم المالك / المدير'), FieldSpec('admin.experience','سنوات الخبرة',numeric:true), FieldSpec('admin.staff','عدد الموظفين',numeric:true), FieldSpec('admin.structure','الهيكل الإداري',multiline:true), FieldSpec('admin.registration','رقم السجل التجاري (إن وجد)')]),
  FormSpec('/operations', 'البيانات التشغيلية', 'المنتجات والطاقة التشغيلية والسوق.', '/financial', [
    FieldSpec('operations.products','المنتجات / الخدمات',multiline:true), FieldSpec('operations.capacity','الطاقة التشغيلية'), FieldSpec('operations.suppliers','الموردون الرئيسيون',multiline:true), FieldSpec('operations.market','السوق المستهدف',multiline:true), FieldSpec('operations.challenges','التحديات التشغيلية',multiline:true)]),
  FormSpec('/financial', 'البيانات المالية والتمويل', 'أدخل أرقاماً تجريبية دون مشاركة بيانات حساسة.', '/cash', [
    FieldSpec('financial.currency','العملة',required:true,options:['ريال يمني','ريال سعودي','دولار أمريكي','أخرى']), FieldSpec('financial.amount','مبلغ التمويل المطلوب',required:true,numeric:true), FieldSpec('financial.purpose','الغرض من التمويل',multiline:true), FieldSpec('financial.duration','المدة المقترحة (بالأشهر)',numeric:true), FieldSpec('financial.revenue','الإيرادات الشهرية',numeric:true), FieldSpec('financial.expenses','المصروفات الشهرية',numeric:true), FieldSpec('financial.debts','الالتزامات القائمة',numeric:true)]),
  FormSpec('/cash', 'التدفقات النقدية', 'تقديرات التدفقات خلال الفترة المحددة.', '/inventory', [
    FieldSpec('cash.period','الفترة',options:['شهري','ربع سنوي','سنوي']), FieldSpec('cash.open','الرصيد الافتتاحي',numeric:true), FieldSpec('cash.in','التدفقات الداخلة',numeric:true), FieldSpec('cash.out','التدفقات الخارجة',numeric:true), FieldSpec('cash.notes','ملاحظات التدفقات',multiline:true)]),
  FormSpec('/inventory', 'بيانات المخزون', 'تفاصيل المخزون المتاح للمشروع، إن وجد.', '/guarantees', [
    FieldSpec('inventory.type','نوع المخزون'), FieldSpec('inventory.quantity','الكمية',numeric:true), FieldSpec('inventory.value','القيمة التقديرية',numeric:true), FieldSpec('inventory.storage','مكان التخزين'), FieldSpec('inventory.notes','ملاحظات',multiline:true)]),
  FormSpec('/guarantees', 'الضمانات', 'وصف الضمانات المقترحة دون افتراض سياسة مصرفية.', '/guarantor', [
    FieldSpec('guarantees.type','نوع الضمان',options:['لا يوجد حالياً','عقار','معدات','أصول أخرى','أخرى']), FieldSpec('guarantees.value','القيمة التقديرية',numeric:true), FieldSpec('guarantees.owner','مالك الضمان'), FieldSpec('guarantees.description','وصف الضمان',multiline:true)]),
  FormSpec('/guarantor', 'بيانات الكفيل', 'تعبئة اختيارية إذا كان هناك كفيل مقترح.', '/documents', [
    FieldSpec('guarantor.status','توفر كفيل',options:['لا يوجد','يوجد']), FieldSpec('guarantor.name','اسم الكفيل'), FieldSpec('guarantor.phone','رقم التواصل'), FieldSpec('guarantor.job','العمل / المهنة'), FieldSpec('guarantor.relationship','صلة الكفيل بصاحب المشروع')]),
];
const steps = <String>['/project','/location','/admin','/operations','/financial','/cash','/inventory','/guarantees','/guarantor','/documents','/photos','/review'];
const stepTitles = <String>['بيانات المشروع','الموقع الجغرافي','البيانات الإدارية','البيانات التشغيلية','البيانات المالية','التدفقات النقدية','المخزون','الضمانات','الكفيل','المستندات','صور المشروع','المراجعة والإرسال'];
