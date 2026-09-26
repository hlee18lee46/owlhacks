import { cn } from '@/lib/utils'

export const APP_STORE_URL = 'https://apps.apple.com/'

function AppleLogo({ className }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="currentColor"
      aria-hidden="true"
      className={className}
    >
      <path d="M16.365 1.43c0 1.14-.46 2.24-1.2 3.03-.8.85-2.1 1.5-3.13 1.42-.13-1.1.42-2.25 1.15-3.01.8-.84 2.2-1.46 3.18-1.44zM20.5 17.1c-.56 1.3-.83 1.88-1.55 3.03-1 1.6-2.42 3.6-4.18 3.61-1.56.02-1.96-1.02-4.08-1-2.12.01-2.56 1.02-4.12 1-1.76-.02-3.1-1.82-4.1-3.42C-.34 16.45-.63 11.2 1.1 8.46 2.33 6.5 4.28 5.36 6.1 5.36c1.86 0 3.03 1.02 4.57 1.02 1.5 0 2.4-1.02 4.56-1.02 1.62 0 3.35.88 4.58 2.41-4.03 2.2-3.37 7.95.69 9.33z" />
    </svg>
  )
}

export function AppStoreButton({
  className,
  variant = 'dark',
}: {
  className?: string
  variant?: 'dark' | 'light'
}) {
  return (
    <a
      href={APP_STORE_URL}
      target="_blank"
      rel="noopener noreferrer"
      className={cn(
        'inline-flex items-center gap-3 rounded-2xl px-5 py-3 transition-transform hover:-translate-y-0.5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring',
        variant === 'dark'
          ? 'bg-secondary text-secondary-foreground'
          : 'bg-card text-card-foreground',
        className,
      )}
    >
      <AppleLogo className="size-7" />
      <span className="flex flex-col leading-tight">
        <span className="text-xs">Download on the</span>
        <span className="font-heading text-lg font-semibold">App Store</span>
      </span>
    </a>
  )
}
