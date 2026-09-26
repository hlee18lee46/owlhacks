import Image from 'next/image'
import { AppStoreButton } from './app-store-button'

export function FinalCta() {
  return (
    <section className="px-5 pb-20">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-8 overflow-hidden rounded-[2.5rem] bg-primary px-6 pt-14 text-center text-primary-foreground md:flex-row md:items-end md:justify-between md:px-14 md:pt-0 md:text-left">
        <div className="flex flex-col items-center gap-6 md:items-start md:py-14">
          <h2 className="max-w-lg text-4xl font-extrabold tracking-tight text-balance md:text-5xl">
            Ready to find out what the hoot is going on?
          </h2>
          <p className="max-w-md text-lg leading-relaxed">
            Free on iPhone. One scan, one owl, one very good selfie.
          </p>
          <AppStoreButton />
        </div>
        <div className="relative aspect-square w-64 shrink-0 md:w-80">
          <Image
            src="/owls/happy.png"
            alt="Smiley Owl waving goodbye"
            fill
            sizes="320px"
            className="object-cover [mask-image:radial-gradient(circle_at_50%_55%,black_45%,transparent_70%)]"
          />
        </div>
      </div>
    </section>
  )
}

export function SiteFooter() {
  return (
    <footer className="border-t border-border">
      <div className="mx-auto flex max-w-6xl flex-col gap-4 px-5 py-8 text-sm text-muted-foreground md:flex-row md:items-center md:justify-between">
        <p>
          © {new Date().getFullYear()} What the Hoot · whatthehoot.health
        </p>
        <p className="max-w-md leading-relaxed">
          For wellness and entertainment only. Not a medical device. Vitals
          powered by Presage.
        </p>
      </div>
    </footer>
  )
}
