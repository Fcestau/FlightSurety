
import DOM from './dom';
import Contract from './contract';
import './flightsurety.css';


(async() => {

    let result = null;

    let contract = new Contract('localhost', () => {

        // Read transaction
        contract.isOperational((error, result) => {
            console.log(error,result);
            display('Operational Status', 'Check if contract is operational', [ { label: 'Operational Status', error: error, value: result} ]);
        });
    

        // User-submitted transaction
        DOM.elid('submit-oracle').addEventListener('click', () => {
            let flight = DOM.elid('flight-number').value;
            // Write transaction
            contract.fetchFlightStatus(flight, (error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        })

        DOM.elid('register-airline').addEventListener('click', async() => {
            let address = DOM.elid('airline-address').value;
            let name = DOM.elid('airline-name').value;
            let sender = DOM.elid('selected-airline-address').value;

            // Write transaction
            contract.registerAirline(address, name, sender, (error, result) => {
                display('', 'New airline address and name: ', [ { label: 'Register Airline', error: error, value: result.message} ]);
                if(error){
                    console.log(error);
                } else if (result.registered == true) {
                    addAirlineOption(name, address);
                }
            });
        })

        DOM.elid('add-funds').addEventListener('click', async() => {
            let funds = DOM.elid('funds-amount').value;
            // Write transaction
            contract.fund(funds, (error, result) => {
                display('', `Funds added`, [ { label: 'Funds added to airline: ', error: error, value: result.funds+" wei"} ]);
                display('', '', [ { label: 'Airline is active: ', value: result.active} ]);
            });
        })

        DOM.elid('register-flight').addEventListener('click', async() => {
            let flight = DOM.elid('flight-number').value;
            let destination = DOM.elid('flight-destination').value;
            
            // Write transaction
            contract.registerFlight(flight, destination, (error, result) => {
                display('', 'Register new flight', [ { label: 'Info:', error: error, value: 'Flight code: '+result.flight + ' Destination: ' + result.destination} ]);
                if (!error) {
                    flightDisplay(flight, destination, result.address, result.timestamp);
                }
            });
        })

        DOM.elid('buy-insurance').addEventListener('click', () => {
            let flight = DOM.elid('insurance-flight-number').value;
            let price = DOM.elid('insurance-amount').value;
            // Write transaction
            contract.buy(flight, price, (error, result) => {
                display('', 'Bought a new flight insurance', [ { label: 'Insurance info', error: error, value: `Flight: ${result.flight}. Paid: ${result.price} wei. Passenger: ${result.passenger}`} ]);
            });
        })

        DOM.elid('claim-credit').addEventListener('click', () => {
            // Write transaction
            contract.pay((error, result) => {
                if(error){
                    console.log(error);
                    alert("Error! Could not withdraw the credit.");
                } else {
                    let creditDisplay = DOM.elid("credit-ammount");
                    alert(`Successfully withdrawed ${creditDisplay.value} wei!`);
                    creditDisplay.value = "0 ethers";
                }
            })
        });
    
    });


    

})();


function display(title, description, results) {
    let displayDiv = DOM.elid("display-wrapper");
    let section = DOM.section();
    section.appendChild(DOM.h2(title));
    section.appendChild(DOM.h5(description));
    results.map((result) => {
        let row = section.appendChild(DOM.div({className:'row'}));
        row.appendChild(DOM.div({className: 'col-sm-4 field'}, result.label));
        row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.error ? String(result.error) : String(result.value)));
        section.appendChild(row);
    })
    displayDiv.append(section);
}
