document.addEventListener('DOMContentLoaded', function() {
    // 投稿処理
    document.getElementById('submit').addEventListener('click', function() {
        const submitForm = document.getElementById('article-submit-form');
        let data = new FormData(submitForm);
        fetch('cgifiles/make-article-html.cgi', {
            method: "POST",
            body: data
        })
        .then(function(response) {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.text();
        })
        .then(function(bodytext) {
            const returnBox = document.getElementById('return-data');
            returnBox.textContent = bodytext;
        });
    }, false);

    // 一覧ページ作成処理
    document.getElementById('submit').addEventListener('click', function() {
        const submitForm = document.getElementById('article-submit-form');
        let data = new FormData(submitForm);
        fetch('cgifiles/make-index-page.cgi', {
            method: "POST",
            body: data
        })
        .then(function(response) {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.text();
        })
        .then(function(bodytext) {
            const returnBox = document.getElementById('return-data');
            returnBox.textContent = bodytext;
        });
    }, false);

    // 入力ページ初期値設定 -----------------------------------------
    // 著作権表示欄初期値
    document.getElementById('copyright').value = "Copyright(c)";

    // 日付欄初期値（現在の日付）
    const now = new Date();
    const year = now.getFullYear().toString();
    const monthTemp = '0' + (now.getMonth() + 1).toString();
    const month = monthTemp.substring(monthTemp.length - 2);
    const dayTemp = '0' + now.getDate().toString();
    const day = dayTemp.substring(dayTemp.length - 2);
    const dateString = `${year}-${month}-${day}`;
    document.getElementById('postdate').value = dateString;

    // 時刻欄初期値（現在の時刻）
    const hourTemp = '0' + now.getHours().toString();
    const hour = hourTemp.substring(hourTemp.length - 2);
    const minuteTemp = '0' + now.getMinutes().toString();
    const minute = minuteTemp.substring(minuteTemp.length - 2);
    const secondTemp = '0' + now.getSeconds().toString();
    const second = secondTemp.substring(secondTemp.length - 2);
    const timeString = `${hour}:${minute}:${second}`;
    document.getElementById('posttime').value = timeString;
}, false);
