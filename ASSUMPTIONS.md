## On requirements

> This application may be command-line or API-only. It does not require a graphical or web interface.

- I assume that IEX is an acceptable medium through which the evaluator can interact with the Elixir API I've written.
- I assume that, though not required, some form of network api may be an acceptable stretch goal. I've chosen to add `Broadway` to this app for ingestion of messages via an external queue. I used `JSON` to parse the messages, as I find it an easy serialization format to work with.

## On design

- I assume members should not be able to request more minutes than they have in their balance. To accomplish this, I added a `:balance` field to the User struct along with a guarded `debit` function.
- ~I assume members should not be able to request an infinite number of visits.~
  - As implementation has continued, I now consider the prompt to be more suitable to a usage scenario in which users are able to request as many visits as they like (within the scope of their remaining balance of minutes). This means the exchange of minutes can be more easily encapsulated in a db transacton. It also makes the Transaction object make a bit more semantic sense than my original assumption.
- I assume it is acceptable to start users with an initial balance for the first iteration.

## On evaluation

- I assume the evaluator has access to an OCI image build tool like `docker`.
