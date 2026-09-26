import Image from 'next/image'
import { APP_STORE_URL } from './app-store-button'

const links = [
  { href: '#how', label: 'How it works' },
  { href: '#owls', label: 'Meet the owls' },
  { href: '#selfie', label: 'Selfie' },
  { href: '#faq', label: 'FAQ' },
]

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-40 border-b border-border/60 bg-background/85 backdrop-blur">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-6 px-5 py-3">
        <a href="#top" className="flex items-center gap-2">
          <span className="relative size-10 overflow-hidden rounded-full bg-sky">
            <Image
              src="/owls/happy.png"
              alt=""
              fill
              sizes="40px"
              className="scale-[1.9] object-cover"
            />
          </span>
          <span className="font-heading text-xl font-bold tracking-tight">
            What the Hoot
          </span>
        </a>
        <nav aria-label="Primary" className="hidden md:block">
          <ul className="flex items-center gap-7 text-sm font-medium text-muted-foreground">
            {links.map((link) => (
              <li key={link.href}>
                <a
                  href={link.href}
                  className="transition-colors hover:text-foreground"
                >
                  {link.label}
                </a>
              </li>
            ))}
          </ul>
        </nav>
        <a
          href={APP_STORE_URL}
          target="_blank"
          rel="noopener noreferrer"
          className="rounded-full bg-secondary px-4 py-2 text-sm font-semibold text-secondary-foreground transition-transform hover:-translate-y-0.5"
        >
          Get the app
        </a>
      </div>
    </header>
  )
}
