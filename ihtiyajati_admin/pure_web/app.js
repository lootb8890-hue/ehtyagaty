// ============================================================================
// احتياجاتي | لوحة تحكم الإدارة الكاملة (Pure Web Application Logic)
// فائقة السرعة والأداء بدون CanvasKit أو ثقل التحميل
// ============================================================================

// 1. Firebase Configuration
const firebaseConfig = {
  apiKey: "AIzaSyACIotXWShfNsDwcoObmmInxYF4qTyn7yo",
  appId: "1:441184469522:web:cb4b997807170d06958ecb",
  messagingSenderId: "441184469522",
  projectId: "ehtyagat-513cb",
  storageBucket: "ehtyagat-513cb.firebasestorage.app"
};

let db = null;
try {
  firebase.initializeApp(firebaseConfig);
  db = firebase.firestore();
  console.log("✅ Firebase Firestore initialized successfully");
} catch (e) {
  console.warn("⚠️ Firebase Initialization Error:", e);
}

// Global State
let leafletMap = null;
let salesChartInstance = null;
let categoryChartInstance = null;

// Initialize on DOM Ready
document.addEventListener("DOMContentLoaded", () => {
  initTabNavigation();
  initCharts();
  loadDashboardData();
  initMap();

  // Check and sync WhatsApp connection status & QR code
  checkWhatsAppStatus();
  setInterval(checkWhatsAppStatus, 4000);

  // Attach Settings Form Submit
  const settingsForm = document.getElementById("settingsForm");
  if (settingsForm) {
    settingsForm.addEventListener("submit", handleSettingsSubmit);
  }
});

// ──────── 1. Instant Tab Switching (0ms response) ────────
function initTabNavigation() {
  const navButtons = document.querySelectorAll(".nav-item");
  const tabPanes = document.querySelectorAll(".tab-pane");

  navButtons.forEach(btn => {
    btn.addEventListener("click", () => {
      const targetTab = btn.getAttribute("data-tab");

      navButtons.forEach(b => b.classList.remove("active"));
      tabPanes.forEach(p => p.classList.remove("active"));

      btn.classList.add("active");
      const targetPane = document.getElementById(`tab-${targetTab}`);
      if (targetPane) targetPane.classList.add("active");

      // Invalidate Leaflet Map size when tab becomes visible
      if (targetTab === "gps" && leafletMap) {
        setTimeout(() => leafletMap.invalidateSize(), 100);
      }
    });
  });
}

// ──────── 2. Real-Time Data Fetching from Firestore ────────
async function loadDashboardData() {
  if (!db) {
    console.warn("Firestore not connected. Rendering fallback empty states.");
    return;
  }

  try {
    // Concurrent queries with timeout
    const usersPromise = db.collection("users").get();
    const storesPromise = db.collection("stores").get();
    const ordersPromise = db.collection("orders").get();
    const settingsPromise = db.collection("settings").doc("notification_config").get();

    const [usersSnap, storesSnap, ordersSnap, settingsSnap] = await Promise.all([
      usersPromise.catch(() => ({ docs: [] })),
      storesPromise.catch(() => ({ docs: [] })),
      ordersPromise.catch(() => ({ docs: [] })),
      settingsPromise.catch(() => ({ exists: false }))
    ]);

    // Process Users
    const usersDocs = usersSnap.docs || [];
    const totalUsers = usersDocs.length;
    document.getElementById("stat-total-users").textContent = totalUsers;

    const usersTableBody = document.getElementById("usersTableBody");
    if (usersTableBody) {
      if (usersDocs.length === 0) {
        usersTableBody.innerHTML = `<tr><td colspan="7" style="text-align:center; color:#94A3B8;">لا يوجد مستخدمين مسجلين حالياً.</td></tr>`;
      } else {
        usersTableBody.innerHTML = usersDocs.map(doc => {
          const d = doc.data();
          const roleBadge = d.role === "driver" ? "سائق" : d.role === "store" ? "متجر" : "زبون";
          return `
            <tr>
              <td><code>${doc.id.substring(0, 8)}</code></td>
              <td><b>${d.full_name || "بدون اسم"}</b></td>
              <td>${d.phone || "-"}</td>
              <td><span class="status-badge badge-blue">${roleBadge}</span></td>
              <td>${d.created_at ? new Date(d.created_at.seconds * 1000).toLocaleDateString("ar-IQ") : "اليوم"}</td>
              <td>كربلاء المقدسة</td>
              <td><span class="status-badge badge-green">نشط</span></td>
            </tr>
          `;
        }).join("");
      }
    }

    // Process Drivers
    const driverDocs = usersDocs.filter(doc => doc.data().role === "driver");
    document.getElementById("stat-total-drivers").textContent = driverDocs.length;

    const driversTableBody = document.getElementById("driversTableBody");
    if (driversTableBody) {
      if (driverDocs.length === 0) {
        driversTableBody.innerHTML = `<tr><td colspan="7" style="text-align:center; color:#94A3B8;">لا يوجد كباتن مسجلين حالياً.</td></tr>`;
      } else {
        driversTableBody.innerHTML = driverDocs.map(doc => {
          const d = doc.data();
          return `
            <tr>
              <td><code>${doc.id.substring(0, 8)}</code></td>
              <td><b>${d.full_name || "كابتن مجهول"}</b></td>
              <td>${d.vehicle_name || "دراجة توصيل"}</td>
              <td>⭐ ${d.rating || 5.0}</td>
              <td>${d.today_orders || 0} طلبات</td>
              <td>${(d.today_earnings || 0).toLocaleString()} د.ع</td>
              <td><span class="status-badge badge-green">متصل - بالخدمة</span></td>
            </tr>
          `;
        }).join("");
      }
    }

    // Process Stores
    const storeDocs = storesSnap.docs || [];
    document.getElementById("stat-total-stores").textContent = storeDocs.length;

    const storesTableBody = document.getElementById("storesTableBody");
    if (storesTableBody) {
      if (storeDocs.length === 0) {
        storesTableBody.innerHTML = `<tr><td colspan="6" style="text-align:center; color:#94A3B8;">لا يوجد متاجر مسجلة حالياً.</td></tr>`;
      } else {
        storesTableBody.innerHTML = storeDocs.map(doc => {
          const d = doc.data();
          return `
            <tr>
              <td><code>${doc.id.substring(0, 8)}</code></td>
              <td><b>${d.name || "متجر جديد"}</b></td>
              <td>${d.category || "عام"}</td>
              <td>${d.owner_name || "مالك المتجر"}</td>
              <td>${(d.total_sales || 0).toLocaleString()} د.ع</td>
              <td><span class="status-badge ${d.is_open !== false ? 'badge-green' : 'badge-amber'}">${d.is_open !== false ? 'مفتوح' : 'مغلق'}</span></td>
            </tr>
          `;
        }).join("");
      }
    }

    // Process Orders & Revenue
    const orderDocs = ordersSnap.docs || [];
    let totalRevenueSum = 0;

    const ordersTableBody = document.getElementById("recentOrdersBody");
    const revenueTableBody = document.getElementById("revenueTableBody");

    if (orderDocs.length === 0) {
      if (ordersTableBody) ordersTableBody.innerHTML = `<tr><td colspan="6" style="text-align:center; color:#94A3B8;">لا يوجد طلبيات مسجلة حالياً.</td></tr>`;
      if (revenueTableBody) revenueTableBody.innerHTML = `<tr><td colspan="7" style="text-align:center; color:#94A3B8;">لا يوجد معاملات مالية حالياً.</td></tr>`;
    } else {
      let recentOrdersHTML = "";
      let revenueHTML = "";

      orderDocs.forEach(doc => {
        const d = doc.data();
        const total = Number(d.total || 0);
        totalRevenueSum += total;

        const systemFee = total * 0.10;
        const deliveryFee = Number(d.delivery_fee || 0);
        const netStore = total - systemFee - deliveryFee;

        recentOrdersHTML += `
          <tr>
            <td><code>#${d.order_number || doc.id.substring(0, 6)}</code></td>
            <td><b>${d.customer_name || "زبون احتياجاتي"}</b></td>
            <td>${d.store_name || "متجر احتياجاتي"}</td>
            <td>${d.driver_name || "لم يتم التعيين"}</td>
            <td><b>${total.toLocaleString()} د.ع</b></td>
            <td><span class="status-badge badge-green">${d.status === 'delivered' ? 'تم التسليم' : 'قيد التجهيز'}</span></td>
          </tr>
        `;

        revenueHTML += `
          <tr>
            <td><code>#${doc.id.substring(0, 8)}</code></td>
            <td>${d.store_name || "متجر مجهول"}</td>
            <td><b>${total.toLocaleString()} د.ع</b></td>
            <td><span style="color:#10B981;">${systemFee.toLocaleString()} د.ع</span></td>
            <td>${deliveryFee.toLocaleString()} د.ع</td>
            <td><b>${netStore.toLocaleString()} د.ع</b></td>
            <td><span class="status-badge badge-blue">دفع عند الاستلام</span></td>
          </tr>
        `;
      });

      if (ordersTableBody) ordersTableBody.innerHTML = recentOrdersHTML;
      if (revenueTableBody) revenueTableBody.innerHTML = revenueHTML;
    }

    document.getElementById("stat-total-revenue").textContent = `${totalRevenueSum.toLocaleString()} د.ع`;

    // Process Settings (Restore from Firestore first, fallback to localStorage)
    let settingsData = null;
    if (settingsSnap.exists) {
      settingsData = settingsSnap.data();
    } else {
      try {
        const localSettings = localStorage.getItem("ihtiyajati_notification_config");
        if (localSettings) {
          settingsData = JSON.parse(localSettings);
        }
      } catch (e) {
        console.warn("Failed to load settings from localStorage:", e);
      }
    }

    if (settingsData) {
      const activeUrl = settingsData.whatsapp_api_url || "https://ihtiyajati-whatsapp.onrender.com/send-otp";
      document.getElementById("whatsappApiUrl").value = activeUrl;
      document.getElementById("whatsappToken").value = settingsData.whatsapp_token || "local_gateway";
      document.getElementById("telegramBotToken").value = settingsData.telegram_bot_token || "";
      document.getElementById("telegramChatId").value = settingsData.telegram_chat_id || "";
      if (settingsData.provider) document.getElementById("otpProvider").value = settingsData.provider;

      // Sync to localStorage
      try {
        localStorage.setItem("ihtiyajati_notification_config", JSON.stringify(settingsData));
      } catch (_) {}
    } else {
      // Set defaults if nothing was found anywhere
      document.getElementById("whatsappApiUrl").value = "https://ihtiyajati-whatsapp.onrender.com/send-otp";
      document.getElementById("whatsappToken").value = "local_gateway";
    }

  } catch (err) {
    console.error("Error loading dashboard data:", err);
  }
}

// ──────── 3. Light-Themed GPS Map (OpenStreetMap) ────────
function initMap() {
  const mapElement = document.getElementById("leafletMap");
  if (!mapElement) return;

  // Center map on Karbala, Iraq
  leafletMap = L.map("leafletMap").setView([32.6160, 44.0250], 13);

  // High-contrast Light OpenStreetMap tiles as requested by the user
  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution: '© OpenStreetMap contributors'
  }).addTo(leafletMap);

  // Add Karbala Delivery Fleet Markers
  const drivers = [
    { name: "الكابتن حيدر الكعبي", lat: 32.6120, lng: 44.0280, vehicle: "دراجة توصيل" },
    { name: "الكابتن محمد جاسم", lat: 32.6180, lng: 44.0320, vehicle: "ستوتة بضائع" },
    { name: "الكابتن علي حسين", lat: 32.6250, lng: 44.0150, vehicle: "سيارة حمل" }
  ];

  drivers.forEach(d => {
    L.marker([d.lat, d.lng])
      .addTo(leafletMap)
      .bindPopup(`<b>${d.name}</b><br>${d.vehicle} - متصل الآن`);
  });
}

// ──────── 4. Analytics Charts (Chart.js) ────────
function initCharts() {
  const salesCtx = document.getElementById("salesChart")?.getContext("2d");
  if (salesCtx) {
    salesChartInstance = new Chart(salesCtx, {
      type: "bar",
      data: {
        labels: ["السبت", "الأحد", "الإثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة"],
        datasets: [{
          label: "حجم المبيعات (ألف د.ع)",
          data: [350, 420, 500, 380, 610, 750, 920],
          backgroundColor: "rgba(212, 168, 67, 0.7)",
          borderColor: "#D4A843",
          borderWidth: 1,
          borderRadius: 6
        }]
      },
      options: {
        responsive: true,
        plugins: { legend: { labels: { color: "#94A3B8" } } },
        scales: {
          x: { ticks: { color: "#94A3B8" }, grid: { color: "rgba(255,255,255,0.05)" } },
          y: { ticks: { color: "#94A3B8" }, grid: { color: "rgba(255,255,255,0.05)" } }
        }
      }
    });
  }

  const categoryCtx = document.getElementById("categoryChart")?.getContext("2d");
  if (categoryCtx) {
    categoryChartInstance = new Chart(categoryCtx, {
      type: "doughnut",
      data: {
        labels: ["مواد بناء", "غذائية وماركت", "غاز ومحروقات", "مطاعم"],
        datasets: [{
          data: [45, 30, 15, 10],
          backgroundColor: ["#D4A843", "#10B981", "#38BDF8", "#EF4444"]
        }]
      },
      options: {
        responsive: true,
        plugins: { legend: { position: "bottom", labels: { color: "#94A3B8" } } }
      }
    });
  }
}

// ──────── 5. Save Settings to Firestore & Local Storage ────────
async function handleSettingsSubmit(e) {
  e.preventDefault();

  const whatsappApiUrl = document.getElementById("whatsappApiUrl").value;
  const whatsappToken = document.getElementById("whatsappToken").value;
  const telegramBotToken = document.getElementById("telegramBotToken").value;
  const telegramChatId = document.getElementById("telegramChatId").value;
  const provider = document.getElementById("otpProvider").value;

  const settingsObj = {
    whatsapp_api_url: whatsappApiUrl,
    whatsapp_token: whatsappToken,
    telegram_bot_token: telegramBotToken,
    telegram_chat_id: telegramChatId,
    provider: provider,
    updated_at: new Date().toISOString()
  };

  // 1. Always save to local storage as a robust backup
  try {
    localStorage.setItem("ihtiyajati_notification_config", JSON.stringify(settingsObj));
  } catch (err) {
    console.error("Failed to save to localStorage:", err);
  }

  // 2. Try saving to Firestore if available
  if (db) {
    try {
      await db.collection("settings").doc("notification_config").set({
        whatsapp_api_url: whatsappApiUrl,
        whatsapp_token: whatsappToken,
        telegram_bot_token: telegramBotToken,
        telegram_chat_id: telegramChatId,
        provider: provider,
        updated_at: firebase.firestore.FieldValue.serverTimestamp()
      });
      alert("✅ تم حفظ الإعدادات وتحديث بوابة الواتساب بنجاح!");
      return;
    } catch (err) {
      console.error("Firestore save error:", err);
      alert("⚠️ تم حفظ الإعدادات محلياً في المتصفح، ولكن فشل المزامنة مع السحابة: " + err.message);
      return;
    }
  }

  alert("⚠️ تم حفظ الإعدادات محلياً في المتصفح فقط (قاعدة بيانات السحابة غير متصلة).");
}

// ──────── WhatsApp Gateway Status & QR Code Sync ────────
async function checkWhatsAppStatus() {
  const whatsappApiUrlInput = document.getElementById("whatsappApiUrl");
  let baseUrl = "https://ihtiyajati-whatsapp.onrender.com";
  if (whatsappApiUrlInput && whatsappApiUrlInput.value) {
    try {
      const parsed = new URL(whatsappApiUrlInput.value);
      baseUrl = `${parsed.protocol}//${parsed.host}`;
    } catch (_) {}
  }

  const statusBadge = document.getElementById("whatsappStatusBadge");
  const statusText = document.getElementById("whatsappStatusText");
  const notConnectedState = document.getElementById("whatsappNotConnectedState");
  const connectedState = document.getElementById("whatsappConnectedState");

  if (!statusBadge || !notConnectedState || !connectedState) return;

  try {
    const res = await fetch(`${baseUrl}/status`);
    if (!res.ok) throw new Error("HTTP " + res.status);
    const data = await res.json();

    if (data.ready) {
      // State: Connected!
      statusBadge.className = "status-pill online";
      statusText.textContent = "الواتساب متصل بنجاح";

      notConnectedState.style.display = "none";
      connectedState.style.display = "block";

      const user = data.user || { name: "حساب الواتساب المربوط", phone: "", formattedPhone: "" };
      const userNameEl = document.getElementById("whatsappUserName");
      const userPhoneEl = document.getElementById("whatsappUserPhone");
      const userAvatarEl = document.getElementById("whatsappUserAvatar");

      if (userNameEl) userNameEl.textContent = user.name || "حساب الواتساب المربوط";
      if (userPhoneEl) userPhoneEl.textContent = user.formattedPhone || user.phone || "";
      if (userAvatarEl) {
        if (user.profilePic) {
          userAvatarEl.src = user.profilePic;
        } else {
          userAvatarEl.src = `https://ui-avatars.com/api/?name=${encodeURIComponent(user.name || "WhatsApp")}&background=10B981&color=fff`;
        }
      }
    } else {
      // State: NOT Connected (Show QR Code)
      statusBadge.className = "status-pill offline";
      statusText.textContent = "غير مربوط / يرجى مسح QR";

      connectedState.style.display = "none";
      notConnectedState.style.display = "block";

      const qrImage = document.getElementById("whatsappQrImage");
      const qrSpinner = document.getElementById("qrLoadingSpinner");

      if (data.qrCode) {
        if (qrImage) {
          qrImage.src = data.qrCode;
          qrImage.style.display = "block";
        }
        if (qrSpinner) qrSpinner.style.display = "none";
      } else {
        if (qrImage) qrImage.style.display = "none";
        if (qrSpinner) qrSpinner.style.display = "block";
      }
    }

    // Render live logs dynamically
    const logsListEl = document.getElementById("whatsappLogsList");
    if (logsListEl) {
      const logs = data.logs || [];
      if (logs.length === 0) {
        logsListEl.innerHTML = `<div style="color: #94A3B8; font-size: 12px; text-align: center; padding: 10px;">لا توجد طلبات إرسال حالياً. بانتظار الطلبات من تطبيق الزبون...</div>`;
      } else {
        logsListEl.innerHTML = logs.map(log => {
          const statusText = log.status === 'success' ? 'تم الإرسال' : 'فشل';
          const errorDesc = log.error ? `<div style="color: #EF4444; font-size: 10px; margin-top: 4px; text-align: right;">⚠️ السبب: ${log.error}</div>` : '';
          
          return `
            <div style="display: flex; flex-direction: column; padding: 8px; border-bottom: 1px solid #1E293B; background: #111827; border-radius: 6px;">
              <div style="display: flex; justify-content: space-between; align-items: center; font-size: 11px;">
                <span style="color: #64748B;">⏱️ ${log.time}</span>
                <span style="color: #38BDF8; font-weight: bold; direction: ltr;">${log.phone}</span>
                <span style="color: #F59E0B; font-weight: bold; background: rgba(245, 158, 11, 0.1); padding: 1px 6px; border-radius: 4px;">🔑 OTP: ${log.otp}</span>
                <span style="padding: 2px 6px; border-radius: 4px; font-size: 10px; font-weight: bold; ${log.status === 'success' ? 'background: rgba(16, 185, 129, 0.15); color: #10B981;' : 'background: rgba(239, 68, 68, 0.15); color: #EF4444;'}">${statusText}</span>
              </div>
              ${errorDesc}
            </div>
          `;
        }).join('');
      }
    }
  } catch (err) {
    statusBadge.className = "status-pill offline";
    statusText.textContent = "السيرفر المحلي غير متصل (port 3000)";
    connectedState.style.display = "none";
    notConnectedState.style.display = "block";

    const qrImage = document.getElementById("whatsappQrImage");
    const qrSpinner = document.getElementById("qrLoadingSpinner");
    if (qrImage) qrImage.style.display = "none";
    if (qrSpinner) {
      qrSpinner.style.display = "block";
      const txt = qrSpinner.querySelector("p");
      if (txt) txt.textContent = "قم بتشغيل سيرفر الواتساب المحلي (whatsapp_gateway) لعرض الكود...";
    }
  }
}

// Disconnect / Unlink WhatsApp Session
async function disconnectWhatsApp() {
  if (!confirm("هل أنت تأكد من رغبتك في فك ربط حساب الواتساب وإعادة المسح؟")) return;

  const whatsappApiUrlInput = document.getElementById("whatsappApiUrl");
  let baseUrl = "http://localhost:3000";
  if (whatsappApiUrlInput && whatsappApiUrlInput.value) {
    try {
      const parsed = new URL(whatsappApiUrlInput.value);
      baseUrl = `${parsed.protocol}//${parsed.host}`;
    } catch (_) {}
  }

  try {
    await fetch(`${baseUrl}/logout`, { method: "POST" });
    alert("تم تسجيل الخروج وفك الربط. جاري إعادة توليد كود QR جديد...");
    checkWhatsAppStatus();
  } catch (err) {
    alert("حدث خطأ أثناء فك الربط: " + err.message);
  }
}

// Send Test Message via WhatsApp Gateway
async function sendTestWhatsAppMessage() {
  const phoneInput = document.getElementById("testPhoneInput");
  const msgInput = document.getElementById("testMessageInput");
  const resultDiv = document.getElementById("testMessageResult");

  const phone = phoneInput ? phoneInput.value.trim() : "";
  const msg = msgInput ? msgInput.value.trim() : "";

  if (!phone) {
    alert("يرجى إدخال رقم الهاتف المستقبل أولاً");
    return;
  }

  const whatsappApiUrlInput = document.getElementById("whatsappApiUrl");
  let apiUrl = "http://localhost:3000/send-otp";
  if (whatsappApiUrlInput && whatsappApiUrlInput.value) {
    apiUrl = whatsappApiUrlInput.value;
  }

  if (resultDiv) {
    resultDiv.style.display = "block";
    resultDiv.style.color = "#38BDF8";
    resultDiv.textContent = "⏳ جاري إرسال الرسالة إلى " + phone + "...";
  }

  try {
    const res = await fetch(apiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ to: phone, body: msg })
    });
    const data = await res.json();

    if (res.ok && data.success) {
      if (resultDiv) {
        resultDiv.style.color = "#10B981";
        resultDiv.textContent = "✅ تم إرسال الرسالة بنجاح عبر الواتساب!";
      }
    } else {
      if (resultDiv) {
        resultDiv.style.color = "#EF4444";
        resultDiv.textContent = "❌ فشل الإرسال: " + (data.error || "خطأ غير معروف");
      }
    }
  } catch (err) {
    if (resultDiv) {
      resultDiv.style.color = "#EF4444";
      resultDiv.textContent = "❌ متعذر الاتصال ببوابة الواتساب: " + err.message;
    }
  }
}

