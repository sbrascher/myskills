# Security Standards

This reference details the security implementations for the Segov authentication system.

## Salted Hashing

Passwords are never stored in plain text. A unique `Salt` is generated for each user and combined with the password using `Cesgranrio.Infra.Cryptography.Tools.Hash`.

```csharp
// Example of checking a password
string hashedInput = Hash.CreateToBase64String(inputPassword, userSalt);
bool isValid = hashedInput == storedHashedPassword;
```

## Account Locking

To prevent brute-force attacks, accounts are locked after a configurable number of failed attempts (`MaximoTentativasLogin`).

- **Threshold:** Usually 5 attempts.
- **Handling:** `TratarSenhaIncorretaAsync` increments the counter and sets `Bloqueado = true` if threshold is reached.
- **Error Message:** `DomainNotificationMessages.AcessoBloqueado` returning `HttpStatusCode.Locked`.

## JWT Bearer Token

Authentication is stateless using JWT.

- **Service:** `JwtService`.
- **Claims:** User ID and MFA status are typically included.
- **Refresh/Expiration:** Configured via `JwtConfiguration`.

## Multi-Factor Authentication (MFA)

If enabled (`MfaConfiguration.Enable`), a code is sent via email during login.

- **Service:** `EmailService`.
- **Persistence:** `IUsuarioMfaRepository`.
- **Flow:** Login (Accepted) -> Send Code -> User calls `ValidarMfaAsync` -> Final Token.

## Recaptcha Protection

Sensitive endpoints are protected with Google reCAPTCHA via the `[AutorizacaoComRecaptcha("action")]` attribute.

- **Requirement:** Frontend must send the recaptcha token in the header.
- **Validation:** Handled by middleware/attribute logic before reaching the controller.
