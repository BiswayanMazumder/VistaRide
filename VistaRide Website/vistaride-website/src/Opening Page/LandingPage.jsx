import React from 'react'
import LandingPage_Laptop from './LandingPage(Laptop)'
import LandingPageMobile from './LandingPage(Mobile)'

export default function LandingPage() {
    return (
        <div className='webbody'>
            <div className="hhbnbdv">
                <LandingPage_Laptop></LandingPage_Laptop>
            </div>
            <div className="jnvjnfjn">
                <LandingPageMobile></LandingPageMobile>
            </div>
        </div>
    )
}
