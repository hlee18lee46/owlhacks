import { Analytics } from '@vercel/analytics/next'
import type { Metadata, Viewport } from 'next'
import { Bricolage_Grotesque, DM_Sans } from 'next/font/google'
import './globals.css'

const bricolage = Bricolage_Grotesque({
  subsets: ['latin'],
  variable: '--font-bricolage',
})
const dmSans = DM_Sans({ subsets: ['latin'], variable: '--font-dm-sans' })

export const metadata: Metadata = {
  metadataBase: new URL('https://whatthehoot.health'),
  title: 'What the Hoot — Check your vitals with a selfie',
  description:
    'What the Hoot is an iOS app that reads your heart rate and breathing rate using just your phone camera, powered by Presage. Get your owl, toss it, and snap a selfie with a happy hoot.',
  keywords: [
    'heart rate app',
    'breathing rate',
    'camera vitals',
    'Presage',
    'wellness game',
    'iOS',
  ],
  openGraph: {
    title: 'What the Hoot',
    description:
      'Your camera reads your heart and breath. Your owl tells you how you’re doing.',
    url: 'https://whatthehoot.health',
    siteName: 'What the Hoot',
    images: ['/owls/happy.png'],
    type: 'website',
  },
  generator: 'v0.app',
  icons: {
    icon: [
      {
        url: '/icon-light-32x32.png',
        media: '(prefers-color-scheme: light)',
      },
      {
        url: '/icon-dark-32x32.png',
        media: '(prefers-color-scheme: dark)',
      },
      {
        url: '/icon.svg',
        type: 'image/svg+xml',
      },
    ],
    apple: '/apple-icon.png',
  },
}

export const viewport: Viewport = {
  colorScheme: 'light',
  themeColor: '#f4f9fb',
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html
      lang="en"
      className={`${bricolage.variable} ${dmSans.variable} bg-background`}
    >
      <body className="font-sans antialiased">
        {children}
        {process.env.NODE_ENV === 'production' && <Analytics />}
      </body>
    </html>
  )
}
