#!/bin/bash

# سكريبت شامل لإنشاء وربط كل شيء على Cloudflare Pages تلقائياً
# Comprehensive script to automatically create and connect everything on Cloudflare Pages

set -e

echo "🚀 بدء إعداد Cloudflare Pages الشامل..."
echo "🚀 Starting comprehensive Cloudflare Pages setup..."

# التحقق من المتغيرات المطلوبة
if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
    echo "❌ خطأ: يجب تعيين CLOUDFLARE_ACCOUNT_ID"
    echo "❌ Error: CLOUDFLARE_ACCOUNT_ID must be set"
    echo "💡 مثال: export CLOUDFLARE_ACCOUNT_ID='your-account-id'"
    exit 1
fi

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "❌ خطأ: يجب تعيين CLOUDFLARE_API_TOKEN"
    echo "❌ Error: CLOUDFLARE_API_TOKEN must be set"
    echo "💡 مثال: export CLOUDFLARE_API_TOKEN='your-api-token'"
    exit 1
fi

echo "✅ المتغيرات المطلوبة متوفرة"
echo "✅ Required environment variables are set"

# 1. بناء المشروع
echo "🔨 بناء المشروع..."
echo "🔨 Building project..."
npm run build

# 2. إنشاء قاعدة بيانات D1
echo "🗄️ إنشاء قاعدة بيانات D1..."
echo "🗄️ Creating D1 database..."
D1_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/d1/database" \
  -d '{
    "name": "cline_db",
    "description": "Database for Cline Webview UI"
  }')

echo "📋 استجابة إنشاء D1:"
echo "📋 D1 creation response:"
echo "$D1_RESPONSE"

# استخراج معرف قاعدة البيانات
D1_ID=$(echo "$D1_RESPONSE" | grep -o '"uuid":"[^"]*"' | cut -d'"' -f4)

if [ -z "$D1_ID" ]; then
    echo "❌ فشل في استخراج معرف قاعدة البيانات D1"
    echo "❌ Failed to extract D1 database ID"
    exit 1
fi

echo "✅ معرف قاعدة البيانات D1: $D1_ID"
echo "✅ D1 database ID: $D1_ID"

# 3. إنشاء مشروع Pages
echo "📄 إنشاء مشروع Pages..."
echo "📄 Creating Pages project..."
PAGES_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects" \
  -d '{
    "name": "cline-webview-ui",
    "production_branch": "main"
  }')

echo "📋 استجابة إنشاء Pages:"
echo "📋 Pages creation response:"
echo "$PAGES_RESPONSE"

# 4. ربط قاعدة البيانات D1 بمشروع Pages
echo "🔗 ربط قاعدة البيانات D1 بمشروع Pages..."
echo "🔗 Binding D1 database to Pages project..."
BINDING_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/cline-webview-ui/bindings" \
  -d "{
    \"binding\": {
      \"type\": \"d1\",
      \"name\": \"DB\",
      \"d1_database_id\": \"$D1_ID\"
    }
  }")

echo "📋 استجابة ربط D1:"
echo "📋 D1 binding response:"
echo "$BINDING_RESPONSE"

# 5. تحديث ملف wrangler.toml
echo "📝 تحديث ملف wrangler.toml..."
echo "📝 Updating wrangler.toml file..."
cat > wrangler.toml << EOF
name = "cline-webview-ui"
pages_build_output_dir = "./webview-ui/build"
compatibility_date = "2025-05-01"

[[d1_databases]]
binding = "DB"
database_name = "cline_db"
database_id = "$D1_ID"
EOF

echo "✅ تم تحديث wrangler.toml"
echo "✅ wrangler.toml updated"

# 6. النشر باستخدام wrangler
echo "🚀 نشر المشروع..."
echo "🚀 Deploying project..."
npx wrangler pages deploy webview-ui/build --project-name=cline-webview-ui --account-id="$CLOUDFLARE_ACCOUNT_ID"

# 7. التحقق من النشر
echo "🔍 التحقق من النشر..."
echo "🔍 Checking deployment..."
DEPLOYMENTS=$(npx wrangler pages deployment list --project-name=cline-webview-ui --account-id="$CLOUDFLARE_ACCOUNT_ID")

echo "📋 قائمة النشرات:"
echo "📋 Deployment list:"
echo "$DEPLOYMENTS"

# 8. الحصول على رابط الموقع
echo "🌐 الحصول على رابط الموقع..."
echo "🌐 Getting site URL..."
SITE_URL=$(curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/cline-webview-ui" | \
  grep -o '"url":"[^"]*"' | cut -d'"' -f4)

if [ -n "$SITE_URL" ]; then
    echo "🎉 تم النشر بنجاح!"
    echo "🎉 Deployment successful!"
    echo "🌐 رابط الموقع: $SITE_URL"
    echo "🌐 Site URL: $SITE_URL"
else
    echo "⚠️ لم يتم العثور على رابط الموقع، تحقق من لوحة التحكم"
    echo "⚠️ Site URL not found, check the dashboard"
fi

# 9. اختبار API
echo "🧪 اختبار API..."
echo "🧪 Testing API..."
if [ -n "$SITE_URL" ]; then
    echo "🔍 اختبار /api/grpc..."
    echo "🔍 Testing /api/grpc..."
    curl -s -X POST \
      -H "Content-Type: application/json" \
      -d '{"service":"cline.StateService","method":"getLatestState","message":{}}' \
      "$SITE_URL/api/grpc" | head -c 200
    echo ""
    
    echo "🔍 اختبار /api/stream..."
    echo "🔍 Testing /api/stream..."
    curl -s -N \
      -H "Accept: text/event-stream" \
      "$SITE_URL/api/stream?service=cline.StateService&method=subscribeToState" | head -c 200
    echo ""
fi

echo "✅ تم إكمال الإعداد الشامل!"
echo "✅ Comprehensive setup completed!"
echo ""
echo "📋 ملخص الإعداد:"
echo "📋 Setup Summary:"
echo "   - قاعدة البيانات D1: $D1_ID"
echo "   - مشروع Pages: cline-webview-ui"
echo "   - رابط الموقع: $SITE_URL"
echo "   - D1 Database: $D1_ID"
echo "   - Pages Project: cline-webview-ui"
echo "   - Site URL: $SITE_URL"