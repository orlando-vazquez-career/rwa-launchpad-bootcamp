# Día 3: inversión mínima + deploy en testnet

## Variación: inversión mínima de 500

`check_variation_gate` (en `src/lib.rs`) rechaza toda inversión menor a **500 unidades** del token de pago con el error nuevo `AmountTooLow` (`Error(Contract, #7)`). `invest()` le pasa `payment_amount` al gate antes de mover fondos.

El test `test_invest_minimum_amount` (en `src/test.rs`) comprueba que invertir 100 falla con `AmountTooLow` sin mover fondos, y que invertir 500 funciona (5 RWA a `price_per_unit = 100`).

```bash
cargo test
stellar contract build
```

## Despliegue en testnet

| | |
|---|---|
| Contract ID | [`CALMIZEWORJQHR2G3354L255YLQ42JMV22LALN43EKBMSWFPTJWA7KEE`](https://stellar.expert/explorer/testnet/contract/CALMIZEWORJQHR2G3354L255YLQ42JMV22LALN43EKBMSWFPTJWA7KEE) |
| Token de pago | XLM nativo (SAC) `CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC`; 1 unidad = 1 stroop |
| Admin (`alice`) | `GCO225B2PDA5IX3XPRQ5HASSAYNDQQTE3QY4KP7TFTLNIPN6IHCP2MVG` |
| Inversionista (`bob`) | `GBE5C7II2ODGWTST3ASLOZM3CTOGF7HXXX42HSBW6QRIJG7L4GA3UGSZ` |
| Inversión exitosa (500) | [`767951f6…d77b8b5`](https://stellar.expert/explorer/testnet/tx/767951f6831163a8d370368563decdbaeb4401377e08d47615ab11958d77b8b5) |

## Flujo completo con los scripts

Los scripts reciben un subcomando. `CONTRACT_ID`, `ADMIN_KEY`, `USER_KEY`, etc. se pueden sobreescribir con variables de entorno.

```bash
# Admin: inicializa y agrega al inversionista a la whitelist
./scripts/admin-tool.sh initialize
./scripts/admin-tool.sh whitelist

# Inversionista
./scripts/user-tool.sh invest 100   # falla: Error(Contract, #7) = AmountTooLow
./scripts/user-tool.sh invest 500   # funciona: devuelve "5"
./scripts/user-tool.sh balance      # "5"
```

La inversión de 100 falla en la simulación, así que la CLI no la envía y no queda transacción on-chain. El error solo se ve en la terminal.
