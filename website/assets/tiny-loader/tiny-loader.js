class TinyLoader {
    static embedFileList(jsonInput) {
        let jsonObj;
        if (typeof jsonInput === 'string') {
            jsonObj = JSON.parse(jsonInput);
        }
        else {
            jsonObj = jsonInput;
        }
        const promises = jsonObj.map((element) => TinyLoader.embedFileElement(element));
        return Promise.all(promises)
            .then((results) => results.every((res) => res === true))
            .catch(() => false);
    }
    static embedFileElement(element) {
        const promises = [];
        if (element.jspath) {
            promises.push(TinyLoader.embedFile(element.jspath));
        }
        if (element.csspath) {
            promises.push(TinyLoader.embedFile(element.csspath));
        }
        return Promise.all(promises)
            .then((results) => results.every((res) => res === true))
            .catch(() => false);
    }
    static embedFile(path) {
        const fileType = TinyLoader.getFileType(path);
        if (fileType === "js") {
            return TinyLoader.embedJsFile(path);
        }
        else if (fileType === "css") {
            return TinyLoader.embedCssFile(path);
        }
        else {
            return Promise.reject(false);
        }
    }
    static embedJsFile(path) {
        return new Promise((resolve, reject) => {
            const scriptElement = document.createElement("script");
            scriptElement.onload = () => resolve(true);
            scriptElement.onerror = () => reject(false);
            scriptElement.src = path;
            document.head.appendChild(scriptElement);
        });
    }
    static embedCssFile(path) {
        return new Promise((resolve, reject) => {
            const cssLinkElement = document.createElement("link");
            cssLinkElement.rel = "stylesheet";
            cssLinkElement.href = path;
            cssLinkElement.onload = () => resolve(true);
            cssLinkElement.onerror = () => reject(false);
            document.head.appendChild(cssLinkElement);
        });
    }
    static loadFile(path) {
        return new Promise((resolve, reject) => {
            const xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        resolve(xhr.responseText);
                    }
                    else {
                        reject(new Error('Failed to load file: ' + path));
                    }
                }
            };
            xhr.open('GET', path, true);
            xhr.send();
        });
    }
    static getFileType(path) {
        const filename = path.split("/").pop();
        if (!filename) {
            return "unknown";
        }
        const lastDotIndex = filename.lastIndexOf(".");
        if (lastDotIndex === -1 || lastDotIndex === undefined) {
            return "unknown";
        }
        return filename.substring(lastDotIndex + 1);
    }
}

