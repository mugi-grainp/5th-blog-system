document.addEventListener('DOMContentLoaded', function() {
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

    document.getElementById('copyright').value = "Copyright(c)";
}, false);
