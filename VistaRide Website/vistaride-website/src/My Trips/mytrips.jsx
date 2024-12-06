import React from 'react'
import Mytripslaptop from './mytrips(laptop)'
import Mytripsmobile from './mytrips(mobile)'

export default function Mytrips() {
    return (
        <div className='webbody'>
            <div className="hhbnbdv">
                <Mytripslaptop />
            </div>
            <div className="jnvjnfjn">
                <Mytripsmobile/>
            </div>
        </div>
    )
}
