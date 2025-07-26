///|
pub(all) struct Spanned[T] {
  v : T
  span : Span
} derive(Show, Eq)

///|
pub fn[T] Spanned::new(v : T, span : Span) -> Spanned[T] {
  { v, span }
}

///|
pub fn[T] Spanned::zero(v : T) -> Spanned[T] {
  let span = { start: 0, end: 0 }
  { v, span }
}

///|
pub fn[T] Spanned::detached(v : T) -> Spanned[T] {
  let span = { start: @int.max_value, end: @int.max_value }
  { v, span }
}

///|
pub fn[T, U] Spanned::map(self : Spanned[T], f : (T) -> U) -> Spanned[U] {
  { v: f(self.v), span: self.span }
}

///|
pub fn[T] Spanned::is_detached(self : Spanned[T]) -> Bool {
  self.span.start == @int.max_value
}

///|
pub(all) struct Span {
  start : Int
  end : Int
} derive(Show, Eq)

///|
pub fn Span::is_empty(self : Span) -> Bool {
  not(self.start < self.end)
}
