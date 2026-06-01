const NOTIF_BASE_URL = 'https://bank-sampah-backend-1079290367613.us-central1.run.app/api';
const NOTIF_REFRESH_MS = 10000;

async function updateNotifBadge() {
    const isNotifPage = window.location.pathname.includes('notifikasi.html');
    if (isNotifPage) {
        localStorage.setItem('last_read_notif_time', new Date().toISOString());
    }

    const lastReadTimeStr = localStorage.getItem('last_read_notif_time') || '1970-01-01T00:00:00.000Z';
    const lastReadTime = new Date(lastReadTimeStr).getTime();

    const clearedTimeStr = localStorage.getItem('cleared_notif_time') || '1970-01-01T00:00:00.000Z';
    const clearedTime = new Date(clearedTimeStr).getTime();

    let total = 0;

    if (!isNotifPage) {
        // 1. Hitung request penjemputan baru
        try {
            const res = await fetch(`${NOTIF_BASE_URL}/request_jemput`);
            if (res.ok) {
                const data = await res.json();
                data.forEach(item => {
                    const itemTime = new Date(item.created_at || item.tanggal_jemput).getTime();
                    if (itemTime > lastReadTime && itemTime > clearedTime) {
                        total++;
                    }
                });
            }
        } catch (e) { }

        // 2. Hitung penukaran voucher baru
        try {
            const res = await fetch(`${NOTIF_BASE_URL}/penukaran`);
            if (res.ok) {
                const data = await res.json();
                data.forEach(item => {
                    const itemTime = new Date(item.tanggal_tukar || item.created_at).getTime();
                    if (itemTime > lastReadTime && itemTime > clearedTime) {
                        total++;
                    }
                });
            }
        } catch (e) { }
    }

    // Update semua badge di halaman
    const badges = document.querySelectorAll('#notif-badge');
    badges.forEach(badge => {
        if (total > 0) {
            badge.textContent = total > 99 ? '99+' : total;
            badge.classList.remove('hidden');
        } else {
            badge.classList.add('hidden');
        }
    });
}

document.addEventListener('DOMContentLoaded', () => {
    updateNotifBadge();
    setInterval(updateNotifBadge, NOTIF_REFRESH_MS);
});
