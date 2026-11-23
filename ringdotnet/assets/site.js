/* RingDotNet documentation: theme, search, copy buttons, table of contents, lightbox */
(function () {
	var root = document.documentElement;
	var saved = null;
	try { saved = localStorage.getItem("rdn-theme"); } catch (e) {}
	if (saved) root.setAttribute("data-theme", saved);
	else if (window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches) root.setAttribute("data-theme", "dark");

	document.addEventListener("DOMContentLoaded", function () {
		var theme = document.getElementById("theme");
		function paint() { theme.textContent = root.getAttribute("data-theme") === "dark" ? "☀" : "☾"; }
		paint();
		theme.addEventListener("click", function () {
			var next = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
			root.setAttribute("data-theme", next);
			try { localStorage.setItem("rdn-theme", next); } catch (e) {}
			paint();
		});

		var menu = document.getElementById("menu");
		menu.addEventListener("click", function () { document.body.classList.toggle("open"); });
		document.querySelector("main").addEventListener("click", function () { document.body.classList.remove("open"); });

		/* keep the current page visible in the sidebar */
		var cur = document.querySelector(".sidebar a.cur");
		if (cur) cur.scrollIntoView({ block: "center" });

		/* copy buttons */
		document.querySelectorAll(".code .copy").forEach(function (b) {
			b.addEventListener("click", function () {
				var text = b.closest(".code").querySelector("pre").innerText;
				var done = function () { b.textContent = "Copied"; setTimeout(function () { b.textContent = "Copy"; }, 1400); };
				if (navigator.clipboard) navigator.clipboard.writeText(text).then(done, done);
				else done();
			});
		});

		/* table of contents */
		var toc = document.getElementById("toc");
		var heads = document.querySelectorAll("article h2[id], article h3[id]");
		if (toc && heads.length > 1) {
			var html = "<h5>On this page</h5>";
			heads.forEach(function (h) {
				var t = h.cloneNode(true);
				t.querySelectorAll(".anchor").forEach(function (a) { a.remove(); });
				html += '<a class="' + (h.tagName === "H3" ? "l3" : "l2") + '" href="#' + h.id + '">' + t.textContent + "</a>";
			});
			toc.innerHTML = html;
			var links = toc.querySelectorAll("a");
			var spy = function () {
				var y = window.scrollY + 120, idx = 0;
				heads.forEach(function (h, i) { if (h.offsetTop <= y) idx = i; });
				links.forEach(function (l, i) { l.classList.toggle("on", i === idx); });
			};
			window.addEventListener("scroll", spy, { passive: true });
			spy();
		} else if (toc) toc.style.display = "none";

		/* a link to a class of the reference opens it */
		function openHash() {
			var h = decodeURIComponent(location.hash.slice(1));
			var e = h ? document.getElementById(h) : null;
			if (e && e.tagName === "DETAILS") { e.open = true; setTimeout(function () { e.scrollIntoView(); }, 30); }
		}
		openHash();
		window.addEventListener("hashchange", openHash);

		/* lightbox */
		var box = document.createElement("div");
		box.className = "lightbox";
		box.innerHTML = "<img alt=''>";
		document.body.appendChild(box);
		box.addEventListener("click", function () { box.classList.remove("on"); });
		document.addEventListener("click", function (e) {
			var img = e.target.closest("figure.shot img, .item .pic img");
			if (!img) return;
			box.firstChild.src = img.src;
			box.classList.add("on");
		});
		document.addEventListener("keydown", function (e) { if (e.key === "Escape") box.classList.remove("on"); });

		/* search */
		var input = document.getElementById("q"), results = document.getElementById("results");
		var index = window.SEARCH_INDEX || [];
		function run() {
			var q = input.value.trim().toLowerCase();
			if (q.length < 2) { results.style.display = "none"; return; }
			var words = q.split(/\s+/), found = [], root = window.SITE_ROOT || "";
			index.forEach(function (e) {
				var hay = (e.t + " " + e.h + " " + e.x).toLowerCase(), score = 0;
				for (var i = 0; i < words.length; i++) {
					if (hay.indexOf(words[i]) < 0) return;
					if (e.t.toLowerCase().indexOf(words[i]) >= 0) score += 5;
					if (e.h.toLowerCase().indexOf(words[i]) >= 0) score += 3;
					score += 1;
				}
				found.push({ e: e, s: score });
			});
			found.sort(function (a, b) { return b.s - a.s; });
			found = found.slice(0, 10);
			/* classes of the reference */
			var classes = [], api = window.API_INDEX || [];
			if (words.length === 1) {
				for (var k = 0; k < api.length && classes.length < 30; k++) {
					var nm = api[k][0].toLowerCase();
					if (nm === words[0]) classes.unshift(api[k]);
					else if (nm.indexOf(words[0]) === 0) classes.push(api[k]);
				}
				for (var k2 = 0; k2 < api.length && classes.length < 30; k2++) {
					var nm2 = api[k2][0].toLowerCase();
					if (nm2.indexOf(words[0]) > 0) classes.push(api[k2]);
				}
				classes = classes.slice(0, 8);
			}
			if (!found.length && !classes.length) { results.innerHTML = "<a><b>No results</b><span>Try another word</span></a>"; results.style.display = "block"; return; }
			var classHtml = classes.map(function (c) {
				return '<a href="' + root + 'api/' + c[1] + '.html#c-' + c[0] + '"><b>' + c[0] + ' <small>' + c[2] + '</small></b><span>' + c[1] + '</span></a>';
			}).join("");
			results.innerHTML = classHtml + found.map(function (f) {
				var e = f.e, snip = e.x, p = snip.toLowerCase().indexOf(words[0]);
				if (p > 40) snip = "…" + snip.substr(p - 40);
				return '<a href="' + root + e.u + '"><b>' + e.t + (e.h ? " › " + e.h : "") + "</b><span>" + snip.substr(0, 110).replace(/</g, "&lt;") + "</span></a>";
			}).join("");
			results.style.display = "block";
		}
		input.addEventListener("input", run);
		input.addEventListener("focus", run);
		document.addEventListener("click", function (e) { if (!e.target.closest(".search")) results.style.display = "none"; });
		document.addEventListener("keydown", function (e) {
			if ((e.key === "/" || (e.ctrlKey && e.key === "k")) && document.activeElement !== input) { e.preventDefault(); input.focus(); }
			if (e.key === "Enter" && document.activeElement === input) { var a = results.querySelector("a[href]"); if (a) location.href = a.href; }
		});
	});
})();
