window.addEventListener('message', function (event) {
    let data = event.data;

    if (data.action === "open") {
        $("#multichar-container").fadeIn(300);
        setupSlots(data.characters, data.maxSlots);
    }

    if (data.action === "close") {
        $("#multichar-container").fadeOut(300);
    }
});

function setupSlots(characters, maxSlots) {
    let slotsContainer = $(".slots-container");
    slotsContainer.html("");

    for (let i = 1; i <= maxSlots; i++) {
        let char = characters[i];
        let html = "";

        if (char) {
            html = `
                <div class="slot-card" onclick="selectSlot(${i}, this)" data-haschar="true">
                    <div class="slot-number">#${i}</div>
                    <div class="slot-name">${char.charinfo.firstname} ${char.charinfo.lastname}</div>
                    <div class="slot-status">Vatandaş</div>
                </div>`;
        } else {
            html = `
                <div class="slot-card empty" onclick="selectSlot(${i}, this)" data-haschar="false">
                    <div class="slot-number">#${i}</div>
                    <div class="slot-name">Boş Slot</div>
                    <div class="slot-status">Yeni Oluştur</div>
                </div>`;
        }

        let element = $(html);
        element.data('info', char);
        slotsContainer.append(element);
    }
}

function selectSlot(index, element) {
    $(".slot-card").removeClass("active");
    $(element).addClass("active");

    let charData = $(element).data('info');
    let hasChar = $(element).data('haschar');

    $("#char-details").fadeIn(200);

    if (hasChar == true && charData) {
        // --- DOLU SLOT İSE ---
        $(".info-grid").css("display", "grid"); // Bilgileri GÖSTER

        $("#char-name").text(charData.charinfo.firstname + " " + charData.charinfo.lastname);
        $("#cash-text").text("$" + charData.money.cash.toLocaleString());
        $("#bank-text").text("$" + charData.money.bank.toLocaleString());
        $("#job-text").text(charData.job.label);
        $("#dob-text").text(charData.charinfo.birthdate);
        $("#gender-text").text(charData.charinfo.gender == 0 ? "Erkek" : "Kadın");

        $("#play-btn").text("Oyna").off('click').click(function () {
            $.post('https://thd_multichar/selectCharacter', JSON.stringify({
                cids: charData.citizenid
            }));
        });

        $.post('https://thd_multichar/previewCharacter', JSON.stringify({
            charData: charData
        }));

    } else {
        // --- BOŞ SLOT İSE ---
        $(".info-grid").hide(); // Bilgileri GİZLE (Sadece isim ve buton kalsın)

        $("#char-name").text("Yeni Karakter");

        $("#play-btn").text("Oluştur").off('click').click(function () {
            $.post('https://thd_multichar/createCharacter', JSON.stringify({
                cid: index
            }));
        });

        $.post('https://thd_multichar/previewCharacter', JSON.stringify({
            charData: null
        }));
    }
}