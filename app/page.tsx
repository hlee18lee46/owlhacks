import { SiteHeader } from '@/components/landing/site-header'
import { Hero } from '@/components/landing/hero'
import { HowItWorks } from '@/components/landing/how-it-works'
import { OwlMoods } from '@/components/landing/owl-moods'
import { SelfieSection } from '@/components/landing/selfie-section'
import { Faq } from '@/components/landing/faq'
import { FinalCta, SiteFooter } from '@/components/landing/final-cta'

export default function Home() {
  return (
    <>
      <SiteHeader />
      <main>
        <Hero />
        <HowItWorks />
        <OwlMoods />
        <SelfieSection />
        <Faq />
        <FinalCta />
      </main>
      <SiteFooter />
    </>
  )
}
