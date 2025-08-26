# Cline Webview UI - Cloudflare Pages Deployment

## 🚀 النشر السريع على Cloudflare Pages

هذا المشروع عبارة عن واجهة مستخدم متقدمة لـ Cline، محسّنة للعمل على Cloudflare Pages مع قاعدة بيانات D1 للبيانات المستمرة.

## ✨ الميزات الرئيسية

- 🌐 **واجهة مستخدم تفاعلية** - تعمل في المتصفح بدون الحاجة لـ VS Code
- 🗄️ **قاعدة بيانات D1** - تخزين مستمر للبيانات
- 🔄 **API حقيقي** - استعلامات عادية وبث مباشر (SSE)
- 📱 **تصميم متجاوب** - يعمل على جميع الأجهزة
- ⚡ **أداء عالي** - مبني على Cloudflare Edge Network
- 🔒 **أمان متقدم** - حماية مدمجة من Cloudflare

## 🛠️ التكنولوجيات المستخدمة

- **Frontend**: React, TypeScript, Vite
- **Backend**: Cloudflare Pages Functions
- **Database**: Cloudflare D1 (SQLite)
- **Deployment**: Cloudflare Pages
- **API**: REST + Server-Sent Events (SSE)

## 📦 التثبيت والنشر

### الطريقة السريعة (الأفضل)

```bash
# 1. استنساخ المشروع
git clone <repository-url>
cd cline-webview-ui

# 2. إعداد المتغيرات البيئية
export CLOUDFLARE_ACCOUNT_ID="your-account-id"
export CLOUDFLARE_API_TOKEN="your-api-token"

# 3. تشغيل النشر التلقائي
./setup-cloudflare.sh
```

### الطريقة اليدوية

```bash
# 1. تثبيت التبعيات
npm install

# 2. بناء المشروع
npm run build

# 3. النشر
npx wrangler pages deploy webview-ui/build \
  --project-name=cline-webview-ui \
  --account-id="$CLOUDFLARE_ACCOUNT_ID"
```

## 🔧 الإعداد

### المتطلبات المسبقة

1. **حساب Cloudflare** مع:
   - معرف الحساب (Account ID)
   - رمز API مع الصلاحيات:
     - `Pages:Edit`
     - `D1:Edit`
     - `Account:Read`

### الحصول على المعرفات

1. **Account ID**: من لوحة تحكم Cloudflare → Workers & Pages → Account ID
2. **API Token**: من لوحة تحكم Cloudflare → My Profile → API Tokens

## 🏗️ هيكل المشروع

```
/
├── webview-ui/              # واجهة المستخدم
│   ├── src/                # الكود المصدري
│   ├── build/              # ملفات البناء
│   └── package.json        # تبعيات الواجهة
├── functions/              # Cloudflare Pages Functions
│   └── api/               # نقاط النهاية API
│       ├── grpc.ts        # API للاستعلامات العادية
│       └── stream.ts      # API للبث المباشر
├── wrangler.toml          # إعدادات Cloudflare
├── setup-cloudflare.sh    # سكريبت النشر التلقائي
└── DEPLOYMENT_GUIDE.md    # دليل النشر المفصل
```

## 🧪 الاختبار

### اختبار API

```bash
# اختبار الاستعلامات العادية
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"service":"cline.StateService","method":"getLatestState","message":{}}' \
  "https://your-site.pages.dev/api/grpc"

# اختبار البث المباشر
curl -N \
  -H "Accept: text/event-stream" \
  "https://your-site.pages.dev/api/stream?service=cline.StateService&method=subscribeToState"
```

### اختبار الواجهة

افتح المتصفح وانتقل إلى:
```
https://your-site.pages.dev
```

## 🔄 النشر التلقائي

تم إعداد GitHub Actions للنشر التلقائي:

1. عند الدفع إلى فرع `main`
2. يتم بناء المشروع تلقائياً
3. يتم النشر إلى Cloudflare Pages
4. يتم تحديث الموقع مباشرة

### إعداد GitHub Secrets

في إعدادات المستودع، أضف:
```
CLOUDFLARE_API_TOKEN=your-api-token
CLOUDFLARE_ACCOUNT_ID=your-account-id
```

## 📊 الميزات المطبقة

### ✅ مكتمل
- [x] واجهة مستخدم تفاعلية
- [x] قاعدة بيانات D1 للبيانات
- [x] API للاستعلامات العادية
- [x] API للبث المباشر (SSE)
- [x] إدارة المهام
- [x] إدارة الحسابات
- [x] إدارة خوادم MCP
- [x] النشر التلقائي
- [x] التحديثات المباشرة
- [x] تصميم متجاوب
- [x] أمان متقدم

### 🔄 قيد التطوير
- [ ] تحسينات الأداء
- [ ] ميزات إضافية
- [ ] تحسينات الأمان

## 🛠️ استكشاف الأخطاء

### مشاكل شائعة

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

### سجلات الأخطاء

```bash
# عرض سجلات wrangler
cat ~/.config/.wrangler/logs/wrangler-*.log

# عرض سجلات النشر
npx wrangler pages deployment list --project-name=cline-webview-ui
```

## 📚 الوثائق

- [دليل النشر المفصل](DEPLOYMENT_GUIDE.md)
- [وثائق Cloudflare Pages](https://developers.cloudflare.com/pages/)
- [وثائق Cloudflare D1](https://developers.cloudflare.com/d1/)

## 🤝 المساهمة

نرحب بالمساهمات! يرجى:

1. Fork المشروع
2. إنشاء فرع للميزة الجديدة
3. Commit التغييرات
4. Push إلى الفرع
5. إنشاء Pull Request

## 📄 الترخيص

هذا المشروع مرخص تحت [MIT License](LICENSE).

## 📞 الدعم

إذا واجهت أي مشاكل:

1. تحقق من [دليل استكشاف الأخطاء](#استكشاف-الأخطاء)
2. راجع [دليل النشر المفصل](DEPLOYMENT_GUIDE.md)
3. افتح issue في GitHub

---

**ملاحظة**: هذا المشروع محسّن للعمل على Cloudflare Pages مع قاعدة بيانات D1. استخدم السكريبت التلقائي للحصول على أسرع تجربة نشر.