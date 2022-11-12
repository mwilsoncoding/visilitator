## On requirements

> This application may be command-line or API-only. It does not require a graphical or web interface.

- I assume that IEX is an acceptable medium through which the evaluator can interact with the Elixir API I've written.
- I assume that, though not required, a web interface may be an acceptable stretch goal.

## On design

- I assume members should not be able to request more minutes than they have in their balance. To accomplish this, I added a `:balance` field to the User struct along with a guarded `debit` function.
- ~I assume members should not be able to request an infinite number of visits.~
  - As implementation has continued, I now consider the prompt to be more suitable to a usage scenario in which users are able to request as many visits as they like (within the scope of their remaining balance of minutes). This means the exchange of minutes can be more easily encapsulated in a db transacton. It also makes the Transaction object make a bit more semantic sense than my original assumption.
- I assume it is acceptable to start users with an initial balance for the first iteration.
- I assume a reasonable stretch goal would be to allow a member to add their insurance information, which would enact a credit to their account per their plan's coverage.
- I assume no data needs to persist beyond the duration of the evaluation of this code test- at least, for the first iteration. The first iteration utilizes Erlang Term Storage for an in-memory storage solution.

## On evaluation

- I assume the evaluator has access to an OCI image build tool like `docker`.
