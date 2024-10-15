const NAV_LINKS = [
    ["About", "/about.html"],
    ["Projects", "/projects.html"],
    ["Blog", "/blog/index.html"],
    ["Contact", "/contact.html"]
]

const HTML = document.lastChild.lastChild;

function createNav() {

    const header = document.createElement("div");
    header.className = "header";

    header.innerHTML = `
    <a href="/index.html">
        <img src="/resources/title.png" class="logo">
        <img src="/resources/title-hover.png" class="logo logo-hover">
    </a>`;

    const nav = document.createElement("nav");
    header.appendChild(nav);

    for (const linkData of NAV_LINKS) {

        const link = document.createElement("a");
        link.innerText = linkData[0];
        link.href = linkData[1];

        nav.appendChild(link);
    }

    HTML.insertBefore(header, HTML.firstChild);

}

createNav();