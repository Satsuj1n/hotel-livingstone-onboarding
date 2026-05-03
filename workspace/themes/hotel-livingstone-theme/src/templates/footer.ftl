<div class="hl-footer__container">
	<div class="hl-footer__brand">
		<strong>Hotel Livingstone</strong>
		<p>Hospedagem boutique. Experiência única.</p>
	</div>

	<#-- URLs relativas: themeDisplay.getURLHome() retorna /web/guest (internal groupName) e dá 404 -->
	<nav class="hl-footer__links" aria-label="<@liferay.language key="secondary-navigation" />">
		<a href="/sobre"><@liferay.language key="about" /></a>
		<a href="/contato"><@liferay.language key="contact" /></a>
	</nav>

	<p class="hl-footer__copyright">
		&copy; ${.now?string("yyyy")} Hotel Livingstone. Todos os direitos reservados.
	</p>
</div>
