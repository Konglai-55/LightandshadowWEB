const header = document.querySelector('.site-header');
const menuToggle = document.querySelector('.menu-toggle');
const navigation = document.querySelector('.site-nav');
const navLinks = [...document.querySelectorAll('.site-nav a[href^="#"]')];
const menuLabel = menuToggle.querySelector('.sr-only');

function syncMenuLabel(open) {
  if (!menuLabel || !window.siteI18n) return;
  menuLabel.textContent = window.siteI18n.translate(open ? 'menuClose' : 'menuOpen');
}

function updateHeader() {
  header.classList.toggle('scrolled', window.scrollY > 24);
}

function closeMenu() {
  navigation.classList.remove('open');
  menuToggle.setAttribute('aria-expanded', 'false');
  document.body.classList.remove('menu-open');
  syncMenuLabel(false);
}

menuToggle.addEventListener('click', () => {
  const open = menuToggle.getAttribute('aria-expanded') === 'true';
  menuToggle.setAttribute('aria-expanded', String(!open));
  navigation.classList.toggle('open', !open);
  document.body.classList.toggle('menu-open', !open);
  syncMenuLabel(!open);
});

navLinks.forEach((link) => link.addEventListener('click', closeMenu));
window.addEventListener('scroll', updateHeader, { passive: true });
updateHeader();
window.addEventListener('site:languagechange', () => {
  syncMenuLabel(menuToggle.getAttribute('aria-expanded') === 'true');
});

const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add('is-visible');
      revealObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.12, rootMargin: '0px 0px -40px' });

document.querySelectorAll('.reveal').forEach((item) => revealObserver.observe(item));

const sectionObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (!entry.isIntersecting) return;
    navLinks.forEach((link) => {
      link.classList.toggle('active', link.getAttribute('href') === `#${entry.target.id}`);
    });
  });
}, { rootMargin: '-35% 0px -58%', threshold: 0 });

document.querySelectorAll('main section[id]').forEach((section) => sectionObserver.observe(section));

const filterButtons = document.querySelectorAll('.project-filters button');
const projectCards = document.querySelectorAll('.project-card');

filterButtons.forEach((button) => {
  button.addEventListener('click', () => {
    const filter = button.dataset.filter;
    filterButtons.forEach((item) => item.classList.toggle('active', item === button));
    projectCards.forEach((card) => {
      const shouldShow = filter === 'all' || card.dataset.category === filter;
      card.classList.toggle('is-hidden', !shouldShow);
    });
    button.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
  });
});

const mobileCta = document.querySelector('.mobile-cta');
const contactSection = document.querySelector('#contact');
if (mobileCta && contactSection) {
  new IntersectionObserver(([entry]) => {
    mobileCta.classList.toggle('is-hidden', entry.isIntersecting);
  }, { threshold: 0.08 }).observe(contactSection);
}

const lightbox = document.querySelector('.lightbox');
const lightboxImage = lightbox.querySelector('img');
const lightboxCaption = lightbox.querySelector('p');

document.querySelectorAll('.project-open').forEach((button) => {
  button.addEventListener('click', () => {
    const source = button.querySelector('img');
    const title = button.querySelector('strong').textContent;
    lightboxImage.src = source.src;
    lightboxImage.alt = source.alt;
    lightboxCaption.textContent = title;
    lightbox.showModal();
  });
});

lightbox.querySelector('.lightbox-close').addEventListener('click', () => lightbox.close());
lightbox.addEventListener('click', (event) => {
  if (event.target === lightbox) lightbox.close();
});

document.getElementById('year').textContent = new Date().getFullYear();
