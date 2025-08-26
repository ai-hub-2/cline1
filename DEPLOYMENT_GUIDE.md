# دليل النشر الشامل على Cloudflare Pages
# Comprehensive Cloudflare Pages Deployment Guide

## 🚀 النشر السريع (Quick Deployment)

### 1. إعداد المتغيرات البيئية (Environment Variables)

```bash
# احصل على معرف الحساب من لوحة تحكم Cloudflare
export CLOUDFLARE_ACCOUNT_ID="your-account-id"

# احصل على رمز API من لوحة تحكم Cloudflare
# يجب أن يحتوي على الصلاحيات: Pages:Edit, D1:Edit
export CLOUDFLARE_API_TOKEN="your-api-token"
```

### 2. تشغيل السكريبت التلقائي (Run Automated Script)

```bash
# تشغيل السكريبت الشامل
./setup-cloudflare.sh
```

## 📋 المتطلبات المسبقة (Prerequisites)

### 1. حساب Cloudflare
- حساب Cloudflare نشط
- معرف الحساب (Account ID)
- رمز API مع الصلاحيات المطلوبة

### 2. الصلاحيات المطلوبة (Required Permissions)
```
- Pages:Edit
- D1:Edit
- Account:Read
```

## 🔧 الإعداد اليدوي (Manual Setup)

### 1. إنشاء قاعدة بيانات D1

```bash
# عبر API مباشرة
curl -X POST \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/d1/database" \
  -d '{
    "name": "cline_db",
    "description": "Database for Cline Webview UI"
  }'
```

### 2. إنشاء مشروع Pages

```bash
curl -X POST \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects" \
  -d '{
    "name": "cline-webview-ui",
    "production_branch": "main"
  }'
```

### 3. ربط قاعدة البيانات D1

```bash
curl -X POST \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/cline-webview-ui/bindings" \
  -d '{
    "binding": {
      "type": "d1",
      "name": "DB",
      "d1_database_id": "YOUR_D1_DATABASE_ID"
    }
  }'
```

### 4. النشر

```bash
# بناء المشروع
npm run build

# النشر
npx wrangler pages deploy webview-ui/build \
  --project-name=cline-webview-ui \
  --account-id="$CLOUDFLARE_ACCOUNT_ID"
```

## 🧪 اختبار النشر (Testing Deployment)

### 1. اختبار API الأساسي

```bash
# اختبار /api/grpc
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"service":"cline.StateService","method":"getLatestState","message":{}}' \
  "https://your-site.pages.dev/api/grpc"

# اختبار /api/stream
curl -N \
  -H "Accept: text/event-stream" \
  "https://your-site.pages.dev/api/stream?service=cline.StateService&method=subscribeToState"
```

### 2. اختبار الواجهة

افتح المتصفح وانتقل إلى:
```
https://your-site.pages.dev
```

## 🔄 النشر التلقائي (Automated Deployment)

### GitHub Actions

تم إعداد النشر التلقائي عبر GitHub Actions. عند الدفع إلى فرع `main`:

1. يتم بناء المشروع تلقائياً
2. يتم النشر إلى Cloudflare Pages
3. يتم تحديث الموقع مباشرة

### إعداد GitHub Secrets

في إعدادات المستودع، أضف:

```
CLOUDFLARE_API_TOKEN=your-api-token
CLOUDFLARE_ACCOUNT_ID=your-account-id
```

## 📁 هيكل الملفات (File Structure)

```
/
├── webview-ui/           # واجهة المستخدم
│   ├── build/           # ملفات البناء
│   ├── src/             # الكود المصدري
│   └── package.json     # تبعيات الواجهة
├── functions/           # Cloudflare Pages Functions
│   └── api/            # نقاط النهاية API
│       ├── grpc.ts     # API للاستعلامات العادية
│       └── stream.ts   # API للبث المباشر
├── wrangler.toml       # إعدادات Cloudflare
├── setup-cloudflare.sh # سكريبت النشر التلقائي
└── package.json        # تبعيات المشروع الرئيسي
```

## 🛠️ استكشاف الأخطاء (Troubleshooting)

### مشاكل شائعة (Common Issues)

1. **خطأ في الصلاحيات**
   ```
   Error: Insufficient permissions
   ```
   **الحل**: تأكد من أن رمز API يحتوي على الصلاحيات المطلوبة

2. **خطأ في قاعدة البيانات D1**
   ```
   Error: Database not found
   ```
   **الحل**: تأكد من إنشاء قاعدة البيانات وربطها بشكل صحيح

3. **خطأ في النشر**
   ```
   Error: Build failed
   ```
   **الحل**: تحقق من ملفات البناء في `webview-ui/build/`

### سجلات الأخطاء (Error Logs)

```bash
# عرض سجلات wrangler
cat ~/.config/.wrangler/logs/wrangler-*.log

# عرض سجلات النشر
npx wrangler pages deployment list --project-name=cline-webview-ui
```

## 📞 الدعم (Support)

إذا واجهت أي مشاكل:

1. تحقق من سجلات الأخطاء
2. تأكد من صحة المتغيرات البيئية
3. تحقق من صلاحيات رمز API
4. راجع إعدادات المشروع في لوحة تحكم Cloudflare

## 🎯 الميزات المطبقة (Implemented Features)

### ✅ مكتمل (Completed)
- [x] واجهة مستخدم تفاعلية
- [x] قاعدة بيانات D1 للبيانات
- [x] API للاستعلامات العادية
- [x] API للبث المباشر (SSE)
- [x] إدارة المهام
- [x] إدارة الحسابات
- [x] إدارة خوادم MCP
- [x] النشر التلقائي
- [x] التحديثات المباشرة

### 🔄 قيد التطوير (In Development)
- [ ] تحسينات الأداء
- [ ] ميزات إضافية
- [ ] تحسينات الأمان

---

**ملاحظة**: هذا الدليل يغطي جميع جوانب النشر على Cloudflare Pages. استخدم السكريبت التلقائي للحصول على أسرع تجربة نشر.