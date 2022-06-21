# PROJECT WORK 2022
Lista API (NodeJS):
- PUT /stato/:idEsp `{"statoEsp":Boolean}`
- PUT /stato `[{"idEsp":"...", "statoEsp":Boolean}, {...}]`
- GET /stato/:idEsp
- GET /lista
- GET /lista/terra
- GET /lista/primo
- GET /lista/posti_occupati
- GET /tempoMedio
- GET /countPosti
- GET /transazioni/settimanaScorsa
- GET /transazioni/settimanaCorrente
- POST /transazioni/:idEsp `{"data_entrata":"YYYY-MM-dd", "pagato":Boolean}`
- PUT /transazioni/:idEsp `{"data_uscita":"YYYY-MM-dd", "importo":Float, "pagato":Boolean}`
- GET /transazioni/completata/:ID_rfid
- GET /transizioni/:ID_rfid

Per avviare app NodeJS: `npm start`

- [ ] Isolare DB dall'esterno, che sia accessibile solo da server NodeJS
