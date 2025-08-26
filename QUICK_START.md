# 🚀 البدء السريع - Cline Webview UI

## ⚡ النشر في 3 خطوات

### 1️⃣ إعداد المتغيرات البيئية

```bash
# احصل على معرف الحساب من لوحة تحكم Cloudflare
export CLOUDFLARE_ACCOUNT_ID="your-account-id"

# احصل على رمز API من لوحة تحكم Cloudflare
export CLOUDFLARE_API_TOKEN="your-api-token"
```

### 2️⃣ تشغيل النشر التلقائي

```bash
# تشغيل السكريبت الشامل
./setup-cloudflare.sh
```

### 3️⃣ الوصول للموقع

سيتم عرض رابط الموقع تلقائياً بعد النشر.

---

## 🔧 كيفية الحصول على المعرفات

### معرف الحساب (Account ID)
1. اذهب إلى [لوحة تحكم Cloudflare](https://dash.cloudflare.com)
2. انظر إلى الجانب الأيمن → Account ID

### رمز API (API Token)
1. اذهب إلى [لوحة تحكم Cloudflare](https://dash.cloudflare.com)
2. My Profile → API Tokens
3. Create Token → Custom token
4. أضف الصلاحيات:
   - `Pages:Edit`
   - `D1:Edit`
   - `Account:Read`

---

## 🎯 النتيجة النهائية

بعد النشر ستحصل على:
- 🌐 موقع يعمل على `https://cline-webview-ui.pages.dev`
- 🗄️ قاعدة بيانات D1 للبيانات
- 🔄 API كامل للواجهة
- 📱 تصميم متجاوب
- ⚡ أداء عالي

---

## 🆘 إذا واجهت مشاكل

1. تحقق من صحة المعرفات
2. تأكد من الصلاحيات
3. راجع [دليل النشر المفصل](DEPLOYMENT_GUIDE.md)
4. تحقق من [دليل استكشاف الأخطاء](README_CLOUDFLARE.md#استكشاف-الأخطاء)

---

**🎉 تهانينا! لديك الآن تطبيق Cline Webview UI يعمل على Cloudflare Pages!**