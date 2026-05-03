<div class="hl-header__container">
	<a class="hl-header__logo" href="${themeDisplay.getURLHome()}" aria-label="<@liferay.language key="home" />">
		<img alt="" src="${images_folder}/logo.png" />
		<span class="hl-header__brand">Hotel Livingstone</span>
	</a>

	<#if has_navigation && is_setup_complete>
		<nav class="hl-header__nav" aria-label="<@liferay.language key="primary-navigation" />">
			<ul>
				<#list nav_items as nav_item>
					<li class="${nav_item.isSelected()?then('is-active', '')}">
						<a href="${nav_item.getURL()}"${nav_item.isSelected()?then(' aria-current="page"', '')}>${nav_item.getName()}</a>
					</li>
				</#list>
			</ul>
		</nav>
	</#if>
</div>
