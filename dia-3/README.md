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
| Contract ID | [`CA42BHJ3P227BGMP4PHFOQTLCNJKWBHRH72A4ZTVVRWV4S5CUROL6BM2`](https://stellar.expert/explorer/testnet/contract/CA42BHJ3P227BGMP4PHFOQTLCNJKWBHRH72A4ZTVVRWV4S5CUROL6BM2) |
| Token de pago | XLM nativo (SAC) `CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC`; 1 unidad = 1 stroop |
| Admin (`alice`) | `GCO225B2PDA5IX3XPRQ5HASSAYNDQQTE3QY4KP7TFTLNIPN6IHCP2MVG` |
| Inversionista (`bob`) | `GBE5C7II2ODGWTST3ASLOZM3CTOGF7HXXX42HSBW6QRIJG7L4GA3UGSZ` |
| Inversión exitosa (500) | [`222bd9cc…5530229`](https://stellar.expert/explorer/testnet/tx/222bd9ccde51cd1f04ef0d18bbbf15468e430ba158b02d404b2f4a4125530229) |

### Desde el frontend (`frontend/dia-3`)

El mismo contrato, operado desde el browser: `alice` agrega a `carol` a la whitelist en `/admin`, y `carol` invierte 100 (rechazada con `AmountTooLow`) y luego 500 en `/invest`.

| | |
|---|---|
| Inversionista (`carol`) | `GDLX3LADYYIBHVWQAVZVTLSALKFANGSRHHI7TSYOWPHPLIAXOMMWC3BO` |
| Whitelist (alice → carol) | [`24698aee…18045e14`](https://stellar.expert/explorer/testnet/tx/24698aeec2a23893b2280610adaf3a0be2b0eeea5f648ad527c0f50918045e14) |
| Inversión exitosa (500) | [`eda20f4b…880baba4`](https://stellar.expert/explorer/testnet/tx/eda20f4b09f496b71400678cb8895020a9233c3f12a73b8913f19a7c880baba4) |

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
