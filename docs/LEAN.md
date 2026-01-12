# Lean 4 Getting Started Guide

A practical guide to the Lean theorem prover, focused on software engineering applications.

## What is Lean?

Lean is a theorem prover and functional programming language. For software engineers, it offers:

- **Formal verification**: Prove your code is correct, not just tested
- **Dependent types**: Types that depend on values (e.g., `Vector n` where `n` is the length)
- **Totality checking**: Guarantee functions terminate and handle all cases
- **Extraction**: Generate executable code from verified proofs

## Installation

### Install elan (Lean version manager)

```bash
# macOS/Linux
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh

# Or via Homebrew
brew install elan-init
```

### Verify installation

```bash
lean --version
lake --version  # Lake is Lean's build system
```

## Project Setup

```bash
# Create a new project
lake new my_project

# Create a mathlib project (for math proofs)
lake new my_math_project math

# Build project
lake build

# Run tests
lake test
```

## Basic Syntax

### Functions and Types

```lean
-- Simple function with explicit types
def double (n : Nat) : Nat :=
  n * 2

-- Type inference
def add (a b : Nat) := a + b

-- Pattern matching
def factorial : Nat -> Nat
  | 0 => 1
  | n + 1 => (n + 1) * factorial n

-- Anonymous functions
def triple := fun n => n * 3

-- Evaluate at compile time
#eval double 21    -- 42
#eval factorial 5  -- 120
```

### Core Types

```lean
-- Primitives
def n : Nat := 42           -- Natural numbers (0, 1, 2, ...)
def i : Int := -10          -- Integers
def s : String := "hello"
def b : Bool := true
def f : Float := 3.14

-- Collections
def xs : List Nat := [1, 2, 3]
def arr : Array Nat := #[1, 2, 3]  -- Efficient arrays
def opt : Option Nat := some 5

-- Tuples and records
def pair : Nat × String := (42, "answer")

structure Point where
  x : Float
  y : Float
```

### Control Flow

```lean
-- If-then-else (expression, not statement)
def abs (n : Int) : Int :=
  if n < 0 then -n else n

-- Match expressions
def describe (n : Nat) : String :=
  match n with
  | 0 => "zero"
  | 1 => "one"
  | _ => "many"

-- Do notation for IO
def main : IO Unit := do
  IO.println "What's your name?"
  let name <- IO.getLine
  IO.println s!"Hello, {name.trim}!"
```

## Practical Examples

### Example 1: Safe Array Access

Regular array access can fail. Lean lets you prove access is safe:

```lean
-- A vector with its length encoded in the type
inductive Vec (α : Type) : Nat -> Type where
  | nil  : Vec α 0
  | cons : α -> Vec α n -> Vec α (n + 1)

-- Safe head: only works on non-empty vectors
def Vec.head : Vec α (n + 1) -> α
  | .cons x _ => x

-- This compiles - we know the vector has 3 elements
def example1 : Nat :=
  let v := Vec.cons 1 (Vec.cons 2 (Vec.cons 3 Vec.nil))
  v.head  -- Returns 1, guaranteed safe

-- This won't compile - can't call head on empty vector
-- def example2 : Nat := Vec.nil.head  -- Type error!
```

### Example 2: Verified Sorting

Prove a sort function actually sorts:

```lean
-- Define what "sorted" means
def isSorted : List Nat -> Bool
  | [] => true
  | [_] => true
  | x :: y :: rest => x <= y && isSorted (y :: rest)

-- A simple insertion sort
def insert (x : Nat) : List Nat -> List Nat
  | [] => [x]
  | y :: ys => if x <= y then x :: y :: ys else y :: insert x ys

def insertionSort : List Nat -> List Nat
  | [] => []
  | x :: xs => insert x (insertionSort xs)

-- Prove it produces sorted output
theorem insertionSort_sorts (xs : List Nat) : 
    isSorted (insertionSort xs) = true := by
  induction xs with
  | nil => rfl
  | cons x xs ih => 
    simp [insertionSort]
    -- ... proof continues
    sorry  -- placeholder for full proof
```

### Example 3: State Machine Verification

Model and verify a simple state machine:

```lean
-- Traffic light states
inductive LightState where
  | red | yellow | green
  deriving Repr, DecidableEq

-- Valid transitions only
inductive ValidTransition : LightState -> LightState -> Prop where
  | red_to_green    : ValidTransition .red .green
  | green_to_yellow : ValidTransition .green .yellow  
  | yellow_to_red   : ValidTransition .yellow .red

-- A transition function that's proven correct
def nextState (s : LightState) : LightState :=
  match s with
  | .red => .green
  | .green => .yellow
  | .yellow => .red

-- Prove every transition is valid
theorem nextState_valid (s : LightState) : 
    ValidTransition s (nextState s) := by
  cases s <;> constructor
```

### Example 4: Parser Combinator with Guarantees

```lean
-- A parser that tracks remaining input length
structure Parser (α : Type) where
  run : (input : String) -> Option (α × { rest : String // rest.length < input.length + 1 })

-- Parse a single character
def char (c : Char) : Parser Unit := {
  run := fun input =>
    if h : input.length > 0 then
      if input.get ⟨0⟩ == c then
        some ((), ⟨input.drop 1, by simp [String.drop]; omega⟩)
      else none
    else none
}

-- Guaranteed termination: each parse consumes input
```

### Example 5: Smart Constructor Pattern

Ensure invariants at construction time:

```lean
-- Email that's validated at construction
structure Email where
  private mk ::
  value : String
  valid : value.contains '@' = true

-- Smart constructor - only way to create Email
def Email.create (s : String) : Option Email :=
  if h : s.contains '@' then
    some { value := s, valid := h }
  else
    none

-- Usage
def sendEmail (email : Email) : IO Unit :=
  IO.println s!"Sending to {email.value}"  -- Guaranteed valid

def example : IO Unit := do
  match Email.create "user@example.com" with
  | some email => sendEmail email
  | none => IO.println "Invalid email"
```

## Key Tactics Reference

| Tactic | Use Case |
|--------|----------|
| `rfl` | Prove equalities that compute to same value |
| `simp` | Simplify using known lemmas |
| `omega` | Solve linear arithmetic (x + 1 > x) |
| `decide` | Prove decidable propositions |
| `exact h` | Use hypothesis `h` as proof |
| `apply f` | Apply theorem/function to goal |
| `intro x` | Introduce variable for forall/implication |
| `cases x` | Case split on `x` |
| `induction x` | Inductive proof on `x` |
| `constructor` | Prove by providing constructor |
| `have h := p` | Introduce intermediate lemma |
| `sorry` | Placeholder (marks proof incomplete) |

## lean.nvim Key Mappings

With `mappings = true` (configured in `home/.config/nvim/lua/plugins/lean.lua`):

| Key | Action |
|-----|--------|
| `<LocalLeader>i` | Toggle infoview (shows goals, types) |
| `<LocalLeader>p` | Pause/unpause infoview |
| `<LocalLeader>r` | Restart Lean server |
| `<LocalLeader><Tab>` | Jump to infoview window |
| `<LocalLeader>\` | Show abbreviation for unicode symbol |

### Unicode Abbreviations

Type `\` + abbreviation in insert mode:

| Input | Output | Meaning |
|-------|--------|---------|
| `\to` | `->` | Function arrow |
| `\fun` | `fun` | Lambda |
| `\forall` | `forall` | Universal quantifier |
| `\exists` | `exists` | Existential quantifier |
| `\and` | `/\` | Logical and |
| `\or` | `\/` | Logical or |
| `\ne` | `!=` | Not equal |
| `\le` | `<=` | Less or equal |
| `\nat` | `Nat` | Natural numbers |
| `\alpha` | `a` | Greek alpha |
| `\x` | `x` | Multiplication |
| `\sub` | `_` | Subscript |

## REPL Commands

```lean
#check expr        -- Show type of expression
#eval expr         -- Evaluate expression
#print name        -- Print definition
#help tactic       -- Tactic documentation
#help term         -- Term-mode help
```

## Project Structure

```
my_project/
├── lakefile.lean     # Build configuration
├── lean-toolchain    # Lean version
├── MyProject.lean    # Main module
├── MyProject/
│   ├── Basic.lean    # Submodules
│   └── Utils.lean
└── lake-manifest.json
```

### lakefile.lean Example

```lean
import Lake
open Lake DSL

package «my_project» where
  version := v!"0.1.0"

lean_lib «MyProject» where
  -- library configuration

@[default_target]
lean_exe «my_project» where
  root := `Main
```

## Resources

| Resource | URL |
|----------|-----|
| Official Docs | https://lean-lang.org/lean4/doc/ |
| Theorem Proving in Lean 4 | https://lean-lang.org/theorem_proving_in_lean4/ |
| Functional Programming in Lean | https://lean-lang.org/functional_programming_in_lean/ |
| Mathematics in Lean | https://leanprover-community.github.io/mathematics_in_lean/ |
| Mathlib4 Docs | https://leanprover-community.github.io/mathlib4_docs/ |
| Zulip Chat | https://leanprover.zulipchat.com/ |
| lean.nvim Wiki | https://github.com/Julian/lean.nvim/wiki |
