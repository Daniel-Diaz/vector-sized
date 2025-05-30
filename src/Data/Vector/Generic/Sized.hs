{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoStarIsType #-}

{-# OPTIONS_GHC -Wno-orphans #-}
{-|
This module reexports the functionality in 'Data.Vector.Generic' which maps well
to explicity sized vectors.

Functions returning a vector determine the size from the type context unless
they have a @'@ suffix in which case they take an explicit 'Proxy' argument.

Functions where the resultant vector size is not know until compile time are
not exported.
-}

module Data.Vector.Generic.Sized
  ( Vector(SomeSized)
  , MVector
   -- * Accessors
   -- ** Length information
  , length
  , length'
  , knownLength
  , knownLength'
    -- ** Indexing
  , index
  , index'
  , unsafeIndex
  , head
  , last
    -- ** Monadic indexing
  , indexM
  , indexM'
  , unsafeIndexM
  , headM
  , lastM
    -- ** Extracting subvectors (slicing)
  , slice
  , slice'
  , init
  , tail
  , take
  , take'
  , drop
  , drop'
  , splitAt
  , splitAt'
  , chunks
    -- * Construction
    -- ** Initialization
  , empty
  , singleton
  , fromTuple
  , BuildVector(..)
  , pattern Build
  , replicate
  , replicate'
  , generate
  , generate'
  , iterateN
  , iterateN'
    -- ** Monadic initialization
  , replicateM
  , replicateM'
  , generateM
  , generateM'
    -- ** Unfolding
  , unfoldrN
  , unfoldrN'
    -- ** Enumeration
  , enumFromN
  , enumFromN'
  , enumFromStepN
  , enumFromStepN'
    -- ** Concatenation
  , cons
  , snoc
  , (++)
    -- ** Restricting memory usage
  , force
    -- * Modifying vectors
    -- ** Bulk updates
  , (//)
  , update
  , update_
  , unsafeUpd
  , unsafeUpdate
  , unsafeUpdate_
    -- ** Accumulations
  , accum
  , accumulate
  , accumulate_
  , unsafeAccum
  , unsafeAccumulate
  , unsafeAccumulate_
    -- ** Permutations
  , reverse
  , backpermute
  , unsafeBackpermute
    -- * Lenses
  , ix
  , ix'
  , _head
  , _last
    -- * Elementwise operations
    -- ** Indexing
  , indexed
    -- ** Mapping
  , map
  , imap
  , concatMap
    -- ** Monadic mapping
  , mapM
  , imapM
  , mapM_
  , imapM_
  , forM
  , forM_
    -- ** Zipping
  , zipWith
  , zipWith3
  , zipWith4
  , zipWith5
  , zipWith6
  , izipWith
  , izipWith3
  , izipWith4
  , izipWith5
  , izipWith6
  , zip
  , zip3
  , zip4
  , zip5
  , zip6
    -- ** Monadic zipping
  , zipWithM
  , izipWithM
  , zipWithM_
  , izipWithM_
    -- ** Unzipping
  , unzip
  , unzip3
  , unzip4
  , unzip5
  , unzip6
    -- * Working with predicates
    -- ** Searching
  , elem
  , notElem
  , find
  , findIndex
  , elemIndex
    -- * Folding
  , foldl
  , foldl1
  , foldl'
  , foldl1'
  , foldr
  , foldr1
  , foldr'
  , foldr1'
  , ifoldl
  , ifoldl'
  , ifoldr
  , ifoldr'
    -- ** Specialised folds
  , all
  , any
  , and
  , or
  , sum
  , product
  , maximum
  , maximumBy
  , minimum
  , minimumBy
  , maxIndex
  , maxIndexBy
  , minIndex
  , minIndexBy
    -- ** Monadic folds
  , foldM
  , ifoldM
  , fold1M
  , foldM'
  , ifoldM'
  , fold1M'
  , foldM_
  , ifoldM_
  , fold1M_
  , foldM'_
  , ifoldM'_
  , fold1M'_
    -- ** Monadic sequencing
  , sequence
  , sequence_
    -- * Prefix sums (scans)
  , prescanl
  , prescanl'
  , postscanl
  , postscanl'
  , scanl
  , scanl'
  , scanl1
  , scanl1'
  , prescanr
  , prescanr'
  , postscanr
  , postscanr'
  , scanr
  , scanr'
  , scanr1
  , scanr1'
    -- * Conversions
    -- ** Lists
  , toList
  , fromList
  , fromListN
  , fromListN'
  , withSizedList
    -- ** Other Vector types
  , convert
    -- ** Mutable vectors
  , freeze
  , thaw
  , copy
  , unsafeFreeze
  , unsafeThaw
    -- ** Unsized Vectors
  , toSized
  , withSized
  , fromSized
  , withVectorUnsafe
  , zipVectorsUnsafe
  ) where

import Data.Vector.Generic.Sized.Internal
import qualified Data.Vector.Generic as VG
import qualified Data.Vector.Generic.Mutable as VGM
import qualified Data.Vector as Boxed
import qualified Data.Vector.Storable as Storable
import qualified Data.Vector.Unboxed as Unboxed
import qualified Data.Vector.Generic.Mutable.Sized as SVGM
import Data.Vector.Generic.Mutable.Sized.Internal
import Data.Binary
import Data.Bits
import Data.Bifunctor
import Data.Foldable (for_)
import Data.Coerce
import Data.Finite hiding (shift)
import Data.Finite.Internal
import Data.Proxy
import qualified Control.Exception as Exception
import Control.Monad (mzero)
import Control.Monad.Primitive
import Control.Monad.ST
import Foreign.Storable
import Data.Data
import Control.Comonad
import Foreign.Ptr (castPtr)
import Data.Semigroup
import Text.Read.Lex
import Text.ParserCombinators.ReadPrec
import GHC.Read
import GHC.TypeLits
import Unsafe.Coerce
import qualified Data.Functor.Rep as Rep
import Data.Distributive
import Prelude
       hiding (Foldable(..), replicate, (++), head, last, init, tail, take,
               drop, splitAt, reverse, map, concatMap, zipWith, zipWith3, zip,
               zip3, unzip, unzip3, notElem,
               all, any, and, or, scanl, scanl1,
               scanr, scanr1, mapM, mapM_, sequence, sequence_)
import Data.IndexedListLiterals hiding (toList, fromList)
import Data.Hashable (Hashable(..))
import qualified Data.IndexedListLiterals as ILL
import Data.Vector.Unboxed (Unbox)
import qualified Data.Traversable.WithIndex as ITraversable
import qualified Data.Foldable.WithIndex as IFoldable
import qualified Data.Functor.WithIndex as IFunctor

instance (KnownNat n, VG.Vector v a, Read (v a)) => Read (Vector v n a) where
  readPrec = parens $ prec 10 $ do
      expectP (Ident "Vector")
      vec <- readPrec
      if VG.length vec == fromIntegral (natVal (Proxy @n)) then return $ Vector vec else pfail

type instance VG.Mutable (Vector v n) = MVector (VG.Mutable v) n

-- | Any sized vector containing 'Storable' elements is itself 'Storable'.
instance (KnownNat n, Storable a, VG.Vector v a)
      => Storable (Vector v n a) where
  sizeOf _ = sizeOf (undefined :: a) * fromIntegral (natVal (Proxy :: Proxy n))
  alignment _ = alignment (undefined :: a)
  peek ptr = generateM (peekElemOff (castPtr ptr) . fromIntegral)
  poke ptr = imapM_ (pokeElemOff (castPtr ptr) . fromIntegral)

-- | The 'Applicative' instance for sized vectors does not have the same
-- behaviour as the 'Applicative' instance for the unsized vectors found in the
-- 'vectors' package. The instance defined here has the same behaviour as the
-- 'Control.Applicative.ZipList' instance.
instance KnownNat n => Applicative (Vector Boxed.Vector n) where
  pure = replicate
  (<*>) = zipWith ($)
  (*>) = seq
  (<*) = flip seq

-- | Treats a @'Data.Vector.Sized.Vector' n a@ as, essentially, a @'Finite'
-- n -> a@, and emulates the 'Monad' instance for that function.
--
-- @'join' :: Vector n (Vector n a) -> Vector n a@ gets the /diagonal/ from
-- a square "matrix".
instance KnownNat n => Monad (Vector Boxed.Vector n) where
  xs >>= f = imap (\i x -> f x `index` i) xs

-- | Non-empty sized vectors are lawful comonads.
--
-- 'extract' is 'head'
--
-- 'duplicate' generates all unique sequences of a vector with the same length as it,
-- using wrap-around.
--
-- e.g.
-- @
-- duplicate [1,2,3,4,5] = [[1,2,3,4,5], [2,3,4,5,1], [3,4,5,1,2], [4,5,1,2,3], [5,1,2,3,4]]
-- @
instance (KnownNat n, n ~ (1 + m)) => Comonad (Vector Boxed.Vector n) where
  extract = head
  extend f r@(Vector v) = Vector $ VG.generate l (\i -> f (Vector (VG.slice i l v')))
    where
      v' = v VG.++ VG.init v
      l = length r

instance (KnownNat n, n ~ (1 + m)) => ComonadApply (Vector Boxed.Vector n) where
  (<@>) = (<*>)
  (<@)  = (<*)
  (@>)  = (*>)

-- | The 'Semigroup' instance for sized vectors does not have the same
-- behaviour as the 'Semigroup' instance for the unsized vectors found in the
-- 'vectors' package. This instance has @(<>) = zipWith (<>)@, but 'vectors'
-- uses concatentation.
instance (Semigroup g, VG.Vector v g) => Semigroup (Vector v n g) where
  (<>) = zipWith (<>)
  stimes = map . stimes

-- | The 'Monoid' instance for sized vectors does not have the same
-- behaviour as the 'Monoid' instance for the unsized vectors found in the
-- 'vectors' package. This instance has @mempty = replicate mempty@ and
-- @mappend = zipWith mappend@, where the 'vectors' instance uses the empty
-- vector and concatenation.
--
-- If 'mempty' is not necessary, using the 'Semigroup' instance over this
-- 'Monoid' will dodge the 'KnownNat' constraint.
instance (Monoid m, VG.Vector v m, KnownNat n) => Monoid (Vector v n m) where
  mempty = replicate mempty
  mconcat vs = generate $ mconcat . flip fmap vs . flip index

instance KnownNat n => Distributive (Vector Boxed.Vector n) where
  distribute = Rep.distributeRep
  {-# inline distribute #-}

instance KnownNat n => Rep.Representable (Vector Boxed.Vector n) where
  type Rep (Vector Boxed.Vector n) = Finite n
  tabulate = generate
  {-# inline tabulate #-}
  index = Data.Vector.Generic.Sized.index
  {-# inline index #-}

instance (Eq a, Hashable a) => Hashable (Vector Boxed.Vector n a) where
  {-# INLINE hashWithSalt #-}
  hashWithSalt salt = hashWithSalt salt . toList

instance (Eq a, Hashable a, Storable a) => Hashable (Vector Storable.Vector n a) where
  {-# INLINE hashWithSalt #-}
  hashWithSalt salt = hashWithSalt salt . toList

instance (Eq a, Hashable a, Unbox a) => Hashable (Vector Unboxed.Vector n a) where
  {-# INLINE hashWithSalt #-}
  hashWithSalt salt = hashWithSalt salt . toList

-- | /O(1)/ Yield the length of the vector as an 'Int'. This is more like
-- 'natVal' than 'Data.Vector.length', extracting the value from the 'KnownNat'
-- instance and not looking at the vector itself.
length :: forall v n a. KnownNat n
       => Vector v n a -> Int
length _ = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline length #-}

-- | /O(1)/ Yield the length of the vector as a 'Proxy'. This function
-- doesn't /do/ anything; it merely allows the size parameter of the vector
-- to be passed around as a 'Proxy'.
length' :: forall v n a.
           Vector v n a -> Proxy n
length' _ = Proxy
{-# inline length' #-}

-- | /O(1)/ Reveal a 'KnownNat' instance for a vector's length, determined
-- at runtime.
knownLength :: forall v n a r. VG.Vector v a
            => Vector v n a -- ^ a vector of some (potentially unknown) length
            -> (KnownNat n => r) -- ^ a value that depends on knowing the vector's length
            -> r -- ^ the value computed with the length
knownLength v x = knownLength' v $ const x

-- | /O(1)/ Reveal a 'KnownNat' instance and 'Proxy' for a vector's length,
-- determined at runtime.
knownLength' :: forall v n a r. VG.Vector v a
             => Vector v n a -- ^ a vector of some (potentially unknown) length
             -> (KnownNat n => Proxy n -> r) -- ^ a value that depends on knowing the vector's length, which is given as a 'Proxy'
             -> r -- ^ the value computed with the length
knownLength' (Vector v) x = case someNatVal (fromIntegral (VG.length v)) of
  Just (SomeNat (Proxy :: Proxy n')) -> case unsafeCoerce Refl :: n' :~: n of Refl -> x Proxy
  Nothing -> error "impossible: Vector has negative length"

-- | /O(1)/ Safe indexing using a 'Finite'.
index :: forall v n a. VG.Vector v a
      => Vector v n a -> Finite n -> a
index (Vector v) (Finite i) = v `VG.unsafeIndex` fromIntegral i
{-# inline index #-}

-- | /O(1)/ Safe indexing using a 'Proxy'.
index' :: forall v n m a p. (KnownNat n, VG.Vector v a)
       => Vector v (n+m+1) a -> p n -> a
index' (Vector v) p = v `VG.unsafeIndex` i
  where i = fromIntegral (natVal p)
{-# inline index' #-}

-- | /O(1)/ Indexing using an 'Int' without bounds checking.
unsafeIndex :: forall v n a. VG.Vector v a
      => Vector v n a -> Int -> a
unsafeIndex (Vector v) i = v `VG.unsafeIndex` i
{-# inline unsafeIndex #-}

-- | /O(1)/ Yield the first element of a non-empty vector.
head :: forall v n a. VG.Vector v a
     => Vector v (1+n) a -> a
head (Vector v) = VG.unsafeHead v
{-# inline head #-}

-- | /O(1)/ Yield the last element of a non-empty vector.
last :: forall v n a. (VG.Vector v a)
     => Vector v (n+1) a -> a
last (Vector v) = VG.unsafeLast v
{-# inline last #-}

-- | Lens to access (/O(1)/) and update (/O(n)/) an arbitrary element by its index.
ix :: forall v n a f. (VG.Vector v a, Functor f)
   => Finite n -> (a -> f a) -> Vector v n a -> f (Vector v n a)
ix n f vector = (\x -> vector // [(n, x)]) <$> f (index vector n)
{-# inline ix #-}

-- | Type-safe lens to access (/O(1)/) and update (/O(n)/) an arbitrary element by its index
-- which should be supplied via TypeApplications.
ix' :: forall i v n a f. (VG.Vector v a, Functor f,
  KnownNat i, KnownNat n, i+1 <= n)
   => (a -> f a) -> Vector v n a -> f (Vector v n a)
ix' = ix (natToFinite (Proxy::Proxy i))
{-# inline ix' #-}

-- | Lens to access (/O(1)/) and update (/O(n)/) the first element of a non-empty vector.
_head :: forall v n a f. (VG.Vector v a, Functor f)
      => (a -> f a) -> Vector v (1+n) a -> f (Vector v (1+n) a)
_head f vector = (\x -> cons x $ tail vector) <$> f (head vector)
{-# inline _head #-}

-- | Lens to access (/O(1)/) and update (/O(n)/) the last element of a non-empty vector.
_last :: forall v n a f. (VG.Vector v a, Functor f)
       => (a -> f a) -> Vector v (n+1) a -> f (Vector v (n+1) a)
_last f vector = snoc (init vector) <$> f (last vector)
{-# inline _last #-}

-- | /O(1)/ Safe indexing in a monad.
--
-- The monad allows operations to be strict in the vector when necessary.
-- Suppose vector copying is implemented like this:
--
-- @
-- copy mv v = ... write mv i (v ! i) ...
-- @
--
-- For lazy vectors, @v ! i@ would not be evaluated, which means that @mv@ would
-- unnecessarily retain a reference to @v@ in each element when written.
--
-- With 'indexM', copying can be implemented like this instead:
--
-- @
-- copy mv v = ... do
--                  x <- indexM v i
--                  write mv i x
-- @
--
-- Here, no references to @v@ are retained, because indexing (but /not/ the
-- elements) are evaluated eagerly.
indexM :: forall v n a m. (VG.Vector v a, Monad m)
      => Vector v n a -> Finite n -> m a
indexM (Vector v) (Finite i) = v `VG.indexM` fromIntegral i
{-# inline indexM #-}

-- | /O(1)/ Safe indexing in a monad using a 'Proxy'. See the documentation for
-- 'indexM' for an explanation of why this is useful.
indexM' :: forall v n k a m p. (KnownNat n, VG.Vector v a, Monad m)
      => Vector v (n+k) a -> p n -> m a
indexM' (Vector v) p = v `VG.indexM` i
  where i = fromIntegral (natVal p)
{-# inline indexM' #-}

-- | /O(1)/ Indexing using an Int without bounds checking. See the
-- documentation for 'indexM' for an explanation of why this is useful.
unsafeIndexM :: forall v n a m. (VG.Vector v a, Monad m)
      => Vector v n a -> Int -> m a
unsafeIndexM (Vector v) i = v `VG.unsafeIndexM` i
{-# inline unsafeIndexM #-}

-- | /O(1)/ Yield the first element of a non-empty vector in a monad. See the
-- documentation for 'indexM' for an explanation of why this is useful.
headM :: forall v n a m. (VG.Vector v a, Monad m)
      => Vector v (1+n) a -> m a
headM (Vector v) = VG.unsafeHeadM v
{-# inline headM #-}

-- | /O(1)/ Yield the last element of a non-empty vector in a monad. See the
-- documentation for 'indexM' for an explanation of why this is useful.
lastM :: forall v n a m. (VG.Vector v a, Monad m)
      => Vector v (n+1) a -> m a
lastM (Vector v) = VG.unsafeLastM v
{-# inline lastM #-}

-- | /O(1)/ Yield a slice of the vector without copying it with an inferred
-- length argument.
slice :: forall v i n m a p. (KnownNat i, KnownNat n, VG.Vector v a)
      => p i -- ^ starting index
      -> Vector v (i+n+m) a
      -> Vector v n a
slice start (Vector v) = Vector (VG.unsafeSlice i n v)
  where i = fromIntegral (natVal start)
        n = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline slice #-}

-- | /O(1)/ Yield a slice of the vector without copying it with an explicit
-- length argument.
slice' :: forall v i n m a p
        . (KnownNat i, KnownNat n, VG.Vector v a)
       => p i -- ^ starting index
       -> p n -- ^ length
       -> Vector v (i+n+m) a
       -> Vector v n a
slice' start _ = slice start
{-# inline slice' #-}

-- | /O(1)/ Yield all but the last element of a non-empty vector without
-- copying.
init :: forall v n a. (VG.Vector v a)
     => Vector v (n+1) a -> Vector v n a
init (Vector v) = Vector (VG.unsafeInit v)
{-# inline init #-}

-- | /O(1)/ Yield all but the first element of a non-empty vector without
-- copying.
tail :: forall v n a. (VG.Vector v a)
     => Vector v (1+n) a -> Vector v n a
tail (Vector v) = Vector (VG.unsafeTail v)
{-# inline tail #-}

-- | /O(1)/ Yield the first @n@ elements. The resulting vector always contains
-- this many elements. The length of the resulting vector is inferred from the
-- type.
take :: forall v n m a. (KnownNat n, VG.Vector v a)
     => Vector v (n+m) a -> Vector v n a
take (Vector v) = Vector (VG.unsafeTake i v)
  where i = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline take #-}

-- | /O(1)/ Yield the first @n@ elements. The resulting vector always contains
-- this many elements. The length of the resulting vector is given explicitly
-- as a 'Proxy' argument.
take' :: forall v n m a p. (KnownNat n, VG.Vector v a)
      => p n -> Vector v (n+m) a -> Vector v n a
take' _ = take
{-# inline take' #-}

-- | /O(1)/ Yield all but the the first @n@ elements. The given vector must
-- contain at least this many elements. The length of the resulting vector is
-- inferred from the type.
drop :: forall v n m a. (KnownNat n, VG.Vector v a)
     => Vector v (n+m) a -> Vector v m a
drop (Vector v) = Vector (VG.unsafeDrop i v)
  where i = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline drop #-}

-- | /O(1)/ Yield all but the the first @n@ elements. The given vector must
-- contain at least this many elements. The length of the resulting vector is
-- givel explicitly as a 'Proxy' argument.
drop' :: forall v n m a p. (KnownNat n, VG.Vector v a)
      => p n -> Vector v (n+m) a -> Vector v m a
drop' _ = drop
{-# inline drop' #-}

-- | /O(1)/ Yield the first @n@ elements, paired with the rest, without copying.
-- The lengths of the resulting vectors are inferred from the type.
splitAt :: forall v n m a. (KnownNat n, VG.Vector v a)
        => Vector v (n+m) a -> (Vector v n a, Vector v m a)
splitAt (Vector v) = (Vector a, Vector b)
  where i = fromIntegral (natVal (Proxy :: Proxy n))
        (a, b) = VG.splitAt i v
{-# inline splitAt #-}

-- | /O(1)/ Yield the first @n@ elements, paired with the rest, without
-- copying.  The length of the first resulting vector is passed explicitly as a
-- 'Proxy' argument.
splitAt' :: forall v n m a p. (KnownNat n, VG.Vector v a)
         => p n -> Vector v (n+m) a -> (Vector v n a, Vector v m a)
splitAt' _ = splitAt
{-# inline splitAt' #-}

-- | /O(n\/m)/ Split a vector into subvectors of equal length.
chunks :: forall v n m a. (KnownNat n, KnownNat m, VG.Vector v a, VG.Vector v (Vector v m a))
       => Vector v (n*m) a -> Vector v n (Vector v m a)
chunks (Vector v) = unfoldrN (first Vector . VG.splitAt m) v
  where
    m :: Int
    m = fromIntegral (natVal (Proxy :: Proxy m))
{-# inline chunks #-}

--------------------------------------------------------------------------------
-- * Construction
--------------------------------------------------------------------------------

--
-- ** Initialization
--

-- | /O(1)/ Empty vector.
empty :: forall v a. (VG.Vector v a)
      => Vector v 0 a
empty = Vector VG.empty
{-# inline empty #-}

-- | /O(1)/ Vector with exactly one element.
singleton :: forall v a. (VG.Vector v a)
           => a -> Vector v 1 a
singleton a = Vector (VG.singleton a)
{-# inline singleton #-}

-- | /O(n)/ Construct a vector in a type-safe manner using a tuple.
-- @
--   fromTuple (1,2) :: Vector v 2 Int
--   fromTuple ("hey", "what's", "going", "on") :: Vector v 4 String
-- @
--
-- @since 1.6.0
fromTuple :: forall v a input length.
             (VG.Vector v a, IndexedListLiterals input length a, KnownNat length)
          => input -> Vector v length a
fromTuple = Vector . VG.fromListN (fromIntegral $ natVal $ Proxy @length) . ILL.toList

infixr 5 :<

-- | @since 1.6.0
data BuildVector (n :: Nat) a where
  -- | @since 1.6.0
  Nil :: BuildVector 0 a
  -- | @since 1.6.0
  (:<) :: a -> BuildVector n a -> BuildVector (1 + n) a

-- | @since 1.6.0
deriving instance Show a => Show (BuildVector n a)

-- | /O(n)/ Construct a vector in a type-safe manner using a sized linked list.
-- @
--   Build (1 :< 2 :< 3 :< Nil) :: Vector v 3 Int
--   Build ("not" :< "much" :< Nil) :: Vector v 2 String
-- @
-- Can also be used as a pattern.
--
-- @since 1.6.0
pattern Build :: VG.Vector v a => BuildVector n a -> Vector v n a
pattern Build build <- ( ( \ ( Vector v ) -> unsafeCoerce $ VG.toList v ) -> build )
  where
    Build vec = Vector . VG.fromList . unsafeCoerce $ vec

-- | /O(n)/ Construct a vector with the same element in each position where the
-- length is inferred from the type.
replicate :: forall v n a. (KnownNat n, VG.Vector v a)
          => a -> Vector v n a
replicate a = Vector (VG.replicate i a)
  where i = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline replicate #-}

-- | /O(n)/ Construct a vector with the same element in each position where the
-- length is given explicitly as a 'Proxy' argument.
replicate' :: forall v n a p. (KnownNat n, VG.Vector v a)
           => p n -> a -> Vector v n a
replicate' _ = replicate
{-# inline replicate' #-}

-- | /O(n)/ Construct a vector of the given length by applying the function to
-- each index where the length is inferred from the type.
generate :: forall v n a. (KnownNat n, VG.Vector v a)
         => (Finite n -> a) -> Vector v n a
generate f = Vector (VG.generate i (f . Finite . fromIntegral))
  where i = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline generate #-}

-- | /O(n)/ Construct a vector of the given length by applying the function to
-- each index where the length is given explicitly as a 'Proxy' argument.
generate' :: forall v n a p. (KnownNat n, VG.Vector v a)
          => p n -> (Finite n -> a) -> Vector v n a
generate' _ = generate
{-# inline generate' #-}

-- | /O(n)/ Apply the function @n@ times to a value. Zeroth element is the original value.
-- The length is inferred from the type.
iterateN :: forall v n a. (KnownNat n, VG.Vector v a)
         => (a -> a) -> a -> Vector v n a
iterateN f z = Vector (VG.iterateN i f z)
  where i = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline iterateN #-}

-- | /O(n)/ Apply the function @n@ times to a value. Zeroth element is the original value.
-- The length is given explicitly as a 'Proxy' argument.
iterateN' :: forall v n a p. (KnownNat n, VG.Vector v a)
          => p n -> (a -> a) -> a -> Vector v n a
iterateN' _ = iterateN
{-# inline iterateN' #-}

--
-- ** Monadic initialisation
--

-- | /O(n)/ Execute the monadic action @n@ times and store the results in a
-- vector where @n@ is inferred from the type.
replicateM :: forall v n m a. (KnownNat n, VG.Vector v a, Monad m)
           => m a -> m (Vector v n a)
replicateM a = Vector <$> VG.replicateM i a
  where i = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline replicateM #-}

-- | /O(n)/ Execute the monadic action @n@ times and store the results in a
-- vector where @n@ is given explicitly as a 'Proxy' argument.
replicateM' :: forall v n m a p. (KnownNat n, VG.Vector v a, Monad m)
            => p n -> m a -> m (Vector v n a)
replicateM' _ = replicateM
{-# inline replicateM' #-}

-- | /O(n)/ Construct a vector of length @n@ by applying the monadic action to
-- each index where @n@ is inferred from the type.
generateM :: forall v n m a. (KnownNat n, VG.Vector v a, Monad m)
          => (Finite n -> m a) -> m (Vector v n a)
generateM f = Vector <$> VG.generateM i (f . Finite . fromIntegral)
  where i = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline generateM #-}

-- | /O(n)/ Construct a vector of length @n@ by applying the monadic action to
-- each index where @n@ is given explicitly as a 'Proxy' argument.
generateM' :: forall v n m a p. (KnownNat n, VG.Vector v a, Monad m)
           => p n -> (Finite n -> m a) -> m (Vector v n a)
generateM' _ = generateM
{-# inline generateM' #-}

--
-- ** Unfolding
--

-- | /O(n)/ Construct a vector with exactly @n@ elements by repeatedly applying
-- the generator function to the a seed. The length is inferred from the
-- type.
unfoldrN :: forall v n a b. (KnownNat n, VG.Vector v a)
         => (b -> (a, b)) -> b -> Vector v n a
unfoldrN f z = Vector (VG.unfoldrN i (Just . f) z)
  where i = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline unfoldrN #-}

-- | /O(n)/ Construct a vector with exactly @n@ elements by repeatedly applying
-- the generator function to the a seed. The length is given explicitly
-- as a 'Proxy' argument.
unfoldrN' :: forall v n a b p. (KnownNat n, VG.Vector v a)
          => p n -> (b -> (a, b)) -> b -> Vector v n a
unfoldrN' _ = unfoldrN
{-# inline unfoldrN' #-}

--
-- ** Enumeration
--

-- | /O(n)/ Yield a vector of length @n@ containing the values @x@, @x+1@,
-- ... @x + (n - 1)@. The length is inferred from the type.
enumFromN :: forall v n a. (KnownNat n, VG.Vector v a, Num a)
          => a -> Vector v n a
enumFromN a = Vector (VG.enumFromN a i)
  where i = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline enumFromN #-}

-- | /O(n)/ Yield a vector of length @n@ containing the values @x@, @x+1@,
-- ..., @x + (n - 1)@ The length is given explicitly as a 'Proxy' argument.
enumFromN' :: forall v n a p. (KnownNat n, VG.Vector v a, Num a)
           => a -> p n -> Vector v n a
enumFromN' a _ = enumFromN a
{-# inline enumFromN' #-}

-- | /O(n)/ Yield a vector of the given length containing the values @x@, @x+y@,
-- @x+2y@, ... @x + (n - 1)y@. The length is inferred from the type.
enumFromStepN :: forall v n a. (KnownNat n, VG.Vector v a, Num a)
          => a -> a -> Vector v n a
enumFromStepN a a' = Vector (VG.enumFromStepN a a' i)
  where i = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline enumFromStepN #-}

-- | /O(n)/ Yield a vector of the given length containing the values @x@, @x+y@,
-- @x+2y@, ..., @x + (n - 1)y@. The length is given explicitly as a 'Proxy' argument.
enumFromStepN' :: forall v n a p. (KnownNat n, VG.Vector v a, Num a)
               => a -> a -> p n -> Vector v n a
enumFromStepN' a a' _ = enumFromStepN a a'
{-# inline enumFromStepN' #-}

--
-- ** Concatenation
--

-- | /O(n)/ Prepend an element.
cons :: forall v n a. VG.Vector v a
     => a -> Vector v n a -> Vector v (1+n) a
cons x (Vector xs) = Vector (VG.cons x xs)
{-# inline cons #-}

-- | /O(n)/ Append an element.
snoc :: forall v n a. VG.Vector v a
     => Vector v n a -> a -> Vector v (n+1) a
snoc (Vector xs) x = Vector (VG.snoc xs x)
{-# inline snoc #-}

-- | /O(m+n)/ Concatenate two vectors.
(++) :: forall v n m a. VG.Vector v a
     => Vector v n a -> Vector v m a -> Vector v (n+m) a
Vector vn ++ Vector vm = Vector (vn VG.++ vm)
{-# inline (++) #-}

--
-- ** Restricting memory usage
--

-- | /O(n)/ Yield the argument but force it not to retain any extra memory,
-- possibly by copying it.
--
-- This is especially useful when dealing with slices. For example:
--
-- > force (slice 0 2 <huge vector>)
--
-- Here, the slice retains a reference to the huge vector. Forcing it creates
-- a copy of just the elements that belong to the slice and allows the huge
-- vector to be garbage collected.
force :: VG.Vector v a => Vector v n a -> Vector v n a
force (Vector v) = Vector (VG.force v)
{-# inline force #-}


--------------------------------------------------------------------------------
-- * Modifying vectors
--------------------------------------------------------------------------------

--
-- ** Bulk updates
--

-- | /O(m+n)/ For each pair @(i,a)@ from the list, replace the vector
-- element at position @i@ by @a@.
--
-- > <5,9,2,7> // [(2,1),(0,3),(2,8)] = <3,9,8,7>
--
(//) :: VG.Vector v a
     => Vector v m a    -- ^ initial vector (of length @m@)
     -> [(Finite m, a)] -- ^ list of index/value pairs (of length @n@)
     -> Vector v m a
Vector v // us = Vector (v VG.// (fmap . first) (fromIntegral . getFinite) us)
{-# inline (//) #-}

-- | /O(m+n)/ For each pair @(i,a)@ from the vector of index/value pairs,
-- replace the vector element at position @i@ by @a@.
--
-- > update <5,9,2,7> <(2,1),(0,3),(2,8)> = <3,9,8,7>
--
update :: (VG.Vector v a, VG.Vector v (Int, a))
        => Vector v m a        -- ^ initial vector (of length @m@)
        -> Vector v n (Int, a) -- ^ vector of index/value pairs (of length @n@)
        -> Vector v m a
update (Vector v) (Vector w) = Vector (VG.update v w)
{-# inline update #-}

-- | /O(m+n)/ For each index @i@ from the index vector and the
-- corresponding value @a@ from the value vector, replace the element of the
-- initial vector at position @i@ by @a@.
--
-- > update_ <5,9,2,7>  <2,0,2> <1,3,8> = <3,9,8,7>
--
-- This function is useful for instances of 'Vector' that cannot store pairs.
-- Otherwise, 'update' is probably more convenient.
--
-- @
-- update_ xs is ys = 'update' xs ('zip' is ys)
-- @
update_ :: (VG.Vector v a, VG.Vector v Int)
        => Vector v m a   -- ^ initial vector (of length @m@)
        -> Vector v n Int -- ^ index vector (of length @n@)
        -> Vector v n a   -- ^ value vector (of length @n@)
        -> Vector v m a
update_ (Vector v) (Vector is) (Vector w) = Vector (VG.update_ v is w)
{-# inline update_ #-}

-- | Same as ('//') but without bounds checking.
unsafeUpd :: (VG.Vector v a)
          => Vector v m a -- ^ initial vector (of length @m@)
          -> [(Int, a)]   -- ^ list of index/value pairs (of length @n@)
          -> Vector v m a
unsafeUpd (Vector v) us = Vector (VG.unsafeUpd v us)
{-# inline unsafeUpd #-}

-- | Same as 'update' but without bounds checking.
unsafeUpdate :: (VG.Vector v a, VG.Vector v (Int, a))
             => Vector v m a        -- ^ initial vector (of length @m@)
             -> Vector v n (Int, a) -- ^ vector of index/value pairs (of length @n@)
             -> Vector v m a
unsafeUpdate (Vector v) (Vector w) = Vector (VG.unsafeUpdate v w)
{-# inline unsafeUpdate #-}

-- | Same as 'update_' but without bounds checking.
unsafeUpdate_ :: (VG.Vector v a, VG.Vector v Int)
              => Vector v m a   -- ^ initial vector (of length @m@)
              -> Vector v n Int -- ^ index vector (of length @n@)
              -> Vector v n a   -- ^ value vector (of length @n@)
              -> Vector v m a
unsafeUpdate_ (Vector v) (Vector is) (Vector w) =
  Vector (VG.unsafeUpdate_ v is w)
{-# inline unsafeUpdate_ #-}

--
-- ** Accumulations
--

-- | /O(m+n)/ For each pair @(i,b)@ from the list, replace the vector element
-- @a@ at position @i@ by @f a b@.
--
-- > accum (+) <5,9,2> [(2,4),(1,6),(0,3),(1,7)] = <5+3, 9+6+7, 2+4>
accum :: VG.Vector v a
      => (a -> b -> a) -- ^ accumulating function @f@
      -> Vector v m a  -- ^ initial vector (of length @m@)
      -> [(Finite m,b)]     -- ^ list of index/value pairs (of length @n@)
      -> Vector v m a
accum f (Vector v) us =
  Vector (VG.accum f v $ (fmap . first) (fromIntegral . getFinite) us)
{-# inline accum #-}

-- | /O(m+n)/ For each pair @(i,b)@ from the vector of pairs, replace the vector
-- element @a@ at position @i@ by @f a b@.
--
-- > accumulate (+) <5,9,2> <(2,4),(1,6),(0,3),(1,7)> = <5+3, 9+6+7, 2+4>
accumulate :: (VG.Vector v a, VG.Vector v (Int, b))
           => (a -> b -> a)      -- ^ accumulating function @f@
           -> Vector v m a       -- ^ initial vector (of length @m@)
           -> Vector v n (Int,b) -- ^ vector of index/value pairs (of length @n@)
           -> Vector v m a
accumulate f (Vector v) (Vector us) = Vector (VG.accumulate f v us)
{-# inline accumulate #-}

-- | /O(m+n)/ For each index @i@ from the index vector and the
-- corresponding value @b@ from the the value vector,
-- replace the element of the initial vector at
-- position @i@ by @f a b@.
--
-- > accumulate_ (+) <5,9,2> <2,1,0,1> <4,6,3,7> = <5+3, 9+6+7, 2+4>
--
-- This function is useful for instances of 'Vector' that cannot store pairs.
-- Otherwise, 'accumulate' is probably more convenient:
--
-- @
-- accumulate_ f as is bs = 'accumulate' f as ('zip' is bs)
-- @
accumulate_ :: (VG.Vector v a, VG.Vector v Int, VG.Vector v b)
            => (a -> b -> a)  -- ^ accumulating function @f@
            -> Vector v m a   -- ^ initial vector (of length @m@)
            -> Vector v n Int -- ^ index vector (of length @n@)
            -> Vector v n b   -- ^ value vector (of length @n@)
            -> Vector v m a
accumulate_ f (Vector v) (Vector is) (Vector xs) = Vector (VG.accumulate_ f v is xs)
{-# inline accumulate_ #-}

-- | Same as 'accum' but without bounds checking.
unsafeAccum :: VG.Vector v a
            => (a -> b -> a) -- ^ accumulating function @f@
            -> Vector v m a  -- ^ initial vector (of length @m@)
            -> [(Int,b)]     -- ^ list of index/value pairs (of length @n@)
            -> Vector v m a
unsafeAccum f (Vector v) us = Vector (VG.unsafeAccum f v us)
{-# inline unsafeAccum #-}

-- | Same as 'accumulate' but without bounds checking.
unsafeAccumulate :: (VG.Vector v a, VG.Vector v (Int, b))
                 => (a -> b -> a)      -- ^ accumulating function @f@
                 -> Vector v m a       -- ^ initial vector (of length @m@)
                 -> Vector v n (Int,b) -- ^ vector of index/value pairs (of length @n@)
                 -> Vector v m a
unsafeAccumulate f (Vector v) (Vector us) = Vector (VG.unsafeAccumulate f v us)
{-# inline unsafeAccumulate #-}

-- | Same as 'accumulate_' but without bounds checking.
unsafeAccumulate_ :: (VG.Vector v a, VG.Vector v Int, VG.Vector v b)
            => (a -> b -> a)  -- ^ accumulating function @f@
            -> Vector v m a   -- ^ initial vector (of length @m@)
            -> Vector v n Int -- ^ index vector (of length @n@)
            -> Vector v n b   -- ^ value vector (of length @n@)
            -> Vector v m a
unsafeAccumulate_ f (Vector v) (Vector is) (Vector xs) = Vector (VG.unsafeAccumulate_ f v is xs)
{-# inline unsafeAccumulate_ #-}

--
-- ** Permutations
--

-- | /O(n)/ Reverse a vector
reverse :: (VG.Vector v a) => Vector v n a -> Vector v n a
reverse (Vector v) = Vector (VG.reverse v)
{-# inline reverse #-}

-- | /O(n)/ Yield the vector obtained by replacing each element @i@ of the
-- index vector by @xs'!'i@. This is equivalent to @'map' (xs'!') is@ but is
-- often much more efficient.
--
-- > backpermute <a,b,c,d> <0,3,2,3,1,0> = <a,d,c,d,b,a>
backpermute :: (VG.Vector v a, VG.Vector v Int)
            => Vector v m a   -- ^ @xs@ value vector
            -> Vector v n Int -- ^ @is@ index vector (of length @n@)
            -> Vector v n a
backpermute (Vector v) (Vector is) = Vector (VG.backpermute v is)
{-# inline backpermute #-}

-- | Same as 'backpermute' but without bounds checking.
unsafeBackpermute :: (VG.Vector v a, VG.Vector v Int)
                  => Vector v m a   -- ^ @xs@ value vector
                  -> Vector v n Int -- ^ @is@ index vector (of length @n@)
                  -> Vector v n a
unsafeBackpermute (Vector v) (Vector is) = Vector (VG.unsafeBackpermute v is)
{-# inline unsafeBackpermute #-}

--------------------------------------------------------------------------------
-- * Elementwise Operations
--------------------------------------------------------------------------------

--
-- ** Indexing
--

-- | /O(n)/ Pair each element in a vector with its index.
indexed :: (VG.Vector v a, VG.Vector v (Int, a), VG.Vector v (Finite n,a))
        => Vector v n a -> Vector v n (Finite n,a)
indexed (Vector v) = Vector ((VG.map . first) (Finite . fromIntegral) $ VG.indexed v)
{-# inline indexed #-}

--
-- ** Mapping
--

-- | /O(n)/ Map a function over a vector.
map :: (VG.Vector v a, VG.Vector v b)
    => (a -> b) -> Vector v n a -> Vector v n b
map f (Vector v) = Vector (VG.map f v)
{-# inline map #-}

-- | /O(n)/ Apply a function to every element of a vector and its index.
imap :: (VG.Vector v a, VG.Vector v b)
     => (Finite n -> a -> b) -> Vector v n a -> Vector v n b
imap f (Vector v) = Vector (VG.imap (f . Finite . fromIntegral) v)
{-# inline imap #-}

-- | /O(n*m)/ Map a function over a vector and concatenate the results. The
-- function is required to always return a vector of the same length.
concatMap :: (VG.Vector v a, VG.Vector v' b)
          => (a -> Vector v' m b) -> Vector v n a -> Vector v' (n*m) b
concatMap f (Vector v) = Vector . VG.concat . fmap (fromSized . f) . VG.toList $ v
{-# inline concatMap #-}

--
-- ** Monadic mapping
--

-- | /O(n)/ Apply the monadic action to all elements of the vector, yielding a
-- vector of results.
mapM :: (Monad m, VG.Vector v a, VG.Vector v b)
      => (a -> m b) -> Vector v n a -> m (Vector v n b)
mapM f (Vector v) = Vector <$> VG.mapM f v
{-# inline mapM #-}

-- | /O(n)/ Apply the monadic action to every element of a vector and its
-- index, yielding a vector of results.
imapM :: (Monad m, VG.Vector v a, VG.Vector v b)
      => (Finite n -> a -> m b) -> Vector v n a -> m (Vector v n b)
imapM f (Vector v) = Vector <$> VG.imapM (f . Finite . fromIntegral) v
{-# inline imapM #-}

-- | /O(n)/ Apply the monadic action to all elements of a vector and ignore the
-- results.
mapM_ :: (Monad m, VG.Vector v a) => (a -> m b) -> Vector v n a -> m ()
mapM_ f (Vector v) = VG.mapM_ f v
{-# inline mapM_ #-}

-- | /O(n)/ Apply the monadic action to every element of a vector and its
-- index, ignoring the results.
imapM_ :: (Monad m, VG.Vector v a) => (Finite n -> a -> m b) -> Vector v n a -> m ()
imapM_ f (Vector v) = VG.imapM_ (f . Finite . fromIntegral) v
{-# inline imapM_ #-}

-- | /O(n)/ Apply the monadic action to all elements of the vector, yielding a
-- vector of results. Equvalent to @flip 'mapM'@.
forM :: (Monad m, VG.Vector v a, VG.Vector v b)
     => Vector v n a -> (a -> m b) -> m (Vector v n b)
forM (Vector v) f = Vector <$> VG.forM v f
{-# inline forM #-}

-- | /O(n)/ Apply the monadic action to all elements of a vector and ignore the
-- results. Equivalent to @flip 'mapM_'@.
forM_ :: (Monad m, VG.Vector v a) => Vector v n a -> (a -> m b) -> m ()
forM_ (Vector v) = VG.forM_ v
{-# inline forM_ #-}

--
-- ** Zipping
--

-- | /O(n)/ Zip two vectors of the same length with the given function.
zipWith :: (VG.Vector v a, VG.Vector v b, VG.Vector v c)
        => (a -> b -> c) -> Vector v n a -> Vector v n b -> Vector v n c
zipWith f (Vector as) (Vector bs) = Vector (VG.zipWith f as bs)
{-# inline zipWith #-}

-- | Zip three vectors with the given function.
zipWith3 :: (VG.Vector v a, VG.Vector v b, VG.Vector v c, VG.Vector v d)
         => (a -> b -> c -> d) -> Vector v n a -> Vector v n b -> Vector v n c -> Vector v n d
zipWith3 f (Vector as) (Vector bs) (Vector cs) = Vector (VG.zipWith3 f as bs cs)
{-# inline zipWith3 #-}

zipWith4 :: (VG.Vector v a,VG.Vector v b,VG.Vector v c,VG.Vector v d,VG.Vector v e)
         => (a -> b -> c -> d -> e)
         -> Vector v n a
         -> Vector v n b
         -> Vector v n c
         -> Vector v n d
         -> Vector v n e
zipWith4 f (Vector as) (Vector bs) (Vector cs) (Vector ds)
  = Vector (VG.zipWith4 f as bs cs ds)
{-# inline zipWith4 #-}

zipWith5 :: (VG.Vector v a,VG.Vector v b,VG.Vector v c,VG.Vector v d,VG.Vector v e,VG.Vector v f)
         => (a -> b -> c -> d -> e -> f)
         -> Vector v n a
         -> Vector v n b
         -> Vector v n c
         -> Vector v n d
         -> Vector v n e
         -> Vector v n f
zipWith5 f (Vector as) (Vector bs) (Vector cs) (Vector ds) (Vector es)
  = Vector (VG.zipWith5 f as bs cs ds es)
{-# inline zipWith5 #-}

zipWith6 :: (VG.Vector v a,VG.Vector v b,VG.Vector v c,VG.Vector v d,VG.Vector v e,VG.Vector v f,VG.Vector v g)
         => (a -> b -> c -> d -> e -> f -> g)
         -> Vector v n a
         -> Vector v n b
         -> Vector v n c
         -> Vector v n d
         -> Vector v n e
         -> Vector v n f
         -> Vector v n g
zipWith6 f (Vector as) (Vector bs) (Vector cs) (Vector ds) (Vector es) (Vector fs)
  = Vector (VG.zipWith6 f as bs cs ds es fs)
{-# inline zipWith6 #-}

-- | /O(n)/ Zip two vectors of the same length with a function that also takes
-- the elements' indices).
izipWith :: (VG.Vector v a,VG.Vector v b,VG.Vector v c)
         => (Finite n -> a -> b -> c)
         -> Vector v n a
         -> Vector v n b
         -> Vector v n c
izipWith f (Vector xs) (Vector ys)
  = Vector (VG.izipWith (f . Finite . fromIntegral) xs ys)
{-# inline izipWith #-}

izipWith3 :: (VG.Vector v a,VG.Vector v b,VG.Vector v c,VG.Vector v d)
          => (Finite n -> a -> b -> c -> d)
          -> Vector v n a
          -> Vector v n b
          -> Vector v n c
          -> Vector v n d
izipWith3 f (Vector as) (Vector bs) (Vector cs)
  = Vector (VG.izipWith3 (f . Finite . fromIntegral) as bs cs)
{-# inline izipWith3 #-}

izipWith4 :: (VG.Vector v a,VG.Vector v b,VG.Vector v c,VG.Vector v d,VG.Vector v e)
          => (Finite n -> a -> b -> c -> d -> e)
          -> Vector v n a
          -> Vector v n b
          -> Vector v n c
          -> Vector v n d
          -> Vector v n e
izipWith4 f (Vector as) (Vector bs) (Vector cs) (Vector ds)
  = Vector (VG.izipWith4 (f . Finite . fromIntegral) as bs cs ds)
{-# inline izipWith4 #-}

izipWith5 :: (VG.Vector v a,VG.Vector v b,VG.Vector v c,VG.Vector v d,VG.Vector v e,VG.Vector v f)
          => (Finite n -> a -> b -> c -> d -> e -> f)
          -> Vector v n a
          -> Vector v n b
          -> Vector v n c
          -> Vector v n d
          -> Vector v n e
          -> Vector v n f
izipWith5 f (Vector as) (Vector bs) (Vector cs) (Vector ds) (Vector es)
  = Vector (VG.izipWith5 (f . Finite . fromIntegral) as bs cs ds es)
{-# inline izipWith5 #-}

izipWith6 :: (VG.Vector v a,VG.Vector v b,VG.Vector v c,VG.Vector v d,VG.Vector v e,VG.Vector v f,VG.Vector v g)
          => (Finite n -> a -> b -> c -> d -> e -> f -> g)
          -> Vector v n a
          -> Vector v n b
          -> Vector v n c
          -> Vector v n d
          -> Vector v n e
          -> Vector v n f
          -> Vector v n g
izipWith6 f (Vector as) (Vector bs) (Vector cs) (Vector ds) (Vector es) (Vector fs)
  = Vector (VG.izipWith6 (f . Finite . fromIntegral) as bs cs ds es fs)
{-# inline izipWith6 #-}

-- | /O(n)/ Zip two vectors of the same length
zip :: (VG.Vector v a, VG.Vector v b, VG.Vector v (a,b))
    => Vector v n a -> Vector v n b -> Vector v n (a, b)
zip = zipWith (,)
{-# inline zip #-}

zip3 :: (VG.Vector v a, VG.Vector v b, VG.Vector v c, VG.Vector v (a, b, c))
     => Vector v n a -> Vector v n b -> Vector v n c -> Vector v n (a, b, c)
zip3 = zipWith3 (,,)
{-# inline zip3 #-}

zip4 :: (VG.Vector v a,VG.Vector v b,VG.Vector v c,VG.Vector v d,VG.Vector v (a,b,c,d))
     => Vector v n a
     -> Vector v n b
     -> Vector v n c
     -> Vector v n d
     -> Vector v n (a,b,c,d)
zip4 = zipWith4 (,,,)
{-# inline zip4 #-}

zip5 :: (VG.Vector v a,VG.Vector v b,VG.Vector v c,VG.Vector v d,VG.Vector v e,VG.Vector v (a,b,c,d,e))
     => Vector v n a
     -> Vector v n b
     -> Vector v n c
     -> Vector v n d
     -> Vector v n e
     -> Vector v n (a,b,c,d,e)
zip5 = zipWith5 (,,,,)
{-# inline zip5 #-}

zip6 :: (VG.Vector v a,VG.Vector v b,VG.Vector v c,VG.Vector v d,VG.Vector v e,VG.Vector v f,VG.Vector v (a,b,c,d,e,f))
     => Vector v n a
     -> Vector v n b
     -> Vector v n c
     -> Vector v n d
     -> Vector v n e
     -> Vector v n f
     -> Vector v n (a,b,c,d,e,f)
zip6 = zipWith6 (,,,,,)
{-# inline zip6 #-}

--
-- ** Monadic zipping
--

-- | /O(n)/ Zip the two vectors of the same length with the monadic action and
-- yield a vector of results.
zipWithM :: (Monad m, VG.Vector v a, VG.Vector v b, VG.Vector v c)
         => (a -> b -> m c) -> Vector v n a -> Vector v n b -> m (Vector v n c)
zipWithM f (Vector as) (Vector bs) = Vector <$> VG.zipWithM f as bs
{-# inline zipWithM #-}

-- | /O(n)/ Zip the two vectors with a monadic action that also takes the
-- element index and yield a vector of results.
izipWithM :: (Monad m, VG.Vector v a, VG.Vector v b, VG.Vector v c)
         => (Finite n -> a -> b -> m c) -> Vector v n a -> Vector v n b -> m (Vector v n c)
izipWithM m (Vector as) (Vector bs) = Vector <$> VG.izipWithM (m . Finite . fromIntegral) as bs
{-# inline izipWithM #-}

-- | /O(n)/ Zip the two vectors with the monadic action and ignore the results.
zipWithM_ :: (Monad m, VG.Vector v a, VG.Vector v b)
          => (a -> b -> m c) -> Vector v n a -> Vector v n b -> m ()
zipWithM_ f (Vector as) (Vector bs) = VG.zipWithM_ f as bs
{-# inline zipWithM_ #-}

-- | /O(n)/ Zip the two vectors with a monadic action that also takes
-- the element index and ignore the results.
izipWithM_ :: (Monad m, VG.Vector v a, VG.Vector v b)
           => (Finite n -> a -> b -> m c) -> Vector v n a -> Vector v n b -> m ()
izipWithM_ m (Vector as) (Vector bs) = VG.izipWithM_ (m . Finite . fromIntegral) as bs
{-# inline izipWithM_ #-}

-- Unzipping
-- ---------

-- | /O(min(m,n))/ Unzip a vector of pairs.
unzip :: (VG.Vector v a, VG.Vector v b, VG.Vector v (a,b))
      => Vector v n (a, b) -> (Vector v n a, Vector v n b)
unzip xs = (map fst xs, map snd xs)
{-# inline unzip #-}

unzip3 :: (VG.Vector v a, VG.Vector v b, VG.Vector v c, VG.Vector v (a, b, c))
       => Vector v n (a, b, c) -> (Vector v n a, Vector v n b, Vector v n c)
unzip3 xs = (map (\(a, _, _) -> a) xs,
             map (\(_, b, _) -> b) xs,
             map (\(_, _, c) -> c) xs)
{-# inline unzip3 #-}

unzip4 :: (VG.Vector v a, VG.Vector v b, VG.Vector v c, VG.Vector v d,
           VG.Vector v (a, b, c, d))
       => Vector v n (a, b, c, d) -> (Vector v n a, Vector v n b, Vector v n c, Vector v n d)
unzip4 xs = (map (\(a, _, _, _) -> a) xs,
             map (\(_, b, _, _) -> b) xs,
             map (\(_, _, c, _) -> c) xs,
             map (\(_, _, _, d) -> d) xs)
{-# inline unzip4 #-}

unzip5 :: (VG.Vector v a, VG.Vector v b, VG.Vector v c, VG.Vector v d, VG.Vector v e,
           VG.Vector v (a, b, c, d, e))
       => Vector v n (a, b, c, d, e) -> (Vector v n a, Vector v n b, Vector v n c, Vector v n d, Vector v n e)
unzip5 xs = (map (\(a, _, _, _, _) -> a) xs,
             map (\(_, b, _, _, _) -> b) xs,
             map (\(_, _, c, _, _) -> c) xs,
             map (\(_, _, _, d, _) -> d) xs,
             map (\(_, _, _, _, e) -> e) xs)
{-# inline unzip5 #-}

unzip6 :: (VG.Vector v a, VG.Vector v b, VG.Vector v c, VG.Vector v d, VG.Vector v e,
           VG.Vector v f, VG.Vector v (a, b, c, d, e, f))
       => Vector v n (a, b, c, d, e, f) -> (Vector v n a, Vector v n b, Vector v n c, Vector v n d, Vector v n e, Vector v n f)
unzip6 xs = (map (\(a, _, _, _, _, _) -> a) xs,
             map (\(_, b, _, _, _, _) -> b) xs,
             map (\(_, _, c, _, _, _) -> c) xs,
             map (\(_, _, _, d, _, _) -> d) xs,
             map (\(_, _, _, _, e, _) -> e) xs,
             map (\(_, _, _, _, _, f) -> f) xs)
{-# inline unzip6 #-}

--------------------------------------------------------------------------------
-- * Working with predicates
--------------------------------------------------------------------------------

--
-- ** Searching
--


infix 4 `elem`
-- | /O(n)/ Check if the vector contains an element.
elem :: (VG.Vector v a, Eq a) => a -> Vector v n a -> Bool
elem x (Vector v) = VG.elem x v
{-# inline elem #-}

infix 4 `notElem`
-- | /O(n)/ Check if the vector does not contain an element (inverse of 'elem').
notElem :: (VG.Vector v a, Eq a) => a -> Vector v n a -> Bool
notElem x (Vector v) = VG.notElem x v
{-# inline notElem #-}

-- | /O(n)/ Yield 'Just' the first element matching the predicate or 'Nothing'
-- if no such element exists.
find :: VG.Vector v a => (a -> Bool) -> Vector v n a -> Maybe a
find f (Vector v) = VG.find f v
{-# inline find #-}

-- | /O(n)/ Yield 'Just' the index of the first element matching the predicate
-- or 'Nothing' if no such element exists.
findIndex :: VG.Vector v a => (a -> Bool) -> Vector v n a -> Maybe (Finite n)
findIndex f (Vector v) = Finite . fromIntegral <$> VG.findIndex f v
{-# inline findIndex #-}

-- | /O(n)/ Yield 'Just' the index of the first occurence of the given element or
-- 'Nothing' if the vector does not contain the element. This is a specialised
-- version of 'findIndex'.
elemIndex :: (VG.Vector v a, Eq a) => a -> Vector v n a -> Maybe (Finite n)
elemIndex x (Vector v) = Finite . fromIntegral <$> VG.elemIndex x v
{-# inline elemIndex #-}

--------------------------------------------------------------------------------
-- * Folding
--------------------------------------------------------------------------------

-- | /O(n)/ Left fold.
foldl :: VG.Vector v b => (a -> b -> a) -> a -> Vector v n b -> a
foldl f z = VG.foldl f z . fromSized
{-# inline foldl #-}

-- | /O(n)/ Left fold on non-empty vectors.
foldl1 :: VG.Vector v a => (a -> a -> a) -> Vector v (1+n) a -> a
foldl1 f = VG.foldl1 f . fromSized
{-# inline foldl1 #-}

-- | /O(n)/ Left fold with strict accumulator.
foldl' :: VG.Vector v b => (a -> b -> a) -> a -> Vector v n b -> a
foldl' f z = VG.foldl' f z . fromSized
{-# inline foldl' #-}

-- | /O(n)/ Left fold on non-empty vectors with strict accumulator.
foldl1' :: VG.Vector v a => (a -> a -> a) -> Vector v (1+n) a -> a
foldl1' f = VG.foldl1' f . fromSized
{-# inline foldl1' #-}

-- | /O(n)/ Right fold.
foldr :: VG.Vector v a => (a -> b -> b) -> b -> Vector v n a -> b
foldr f z = VG.foldr f z . fromSized
{-# inline foldr #-}

-- | /O(n)/ Right fold on non-empty vectors.
foldr1 :: VG.Vector v a => (a -> a -> a) -> Vector v (n+1) a -> a
foldr1 f = VG.foldr1 f . fromSized
{-# inline foldr1 #-}

-- | /O(n)/ Right fold with a strict accumulator.
foldr' :: VG.Vector v a => (a -> b -> b) -> b -> Vector v n a -> b
foldr' f z = VG.foldr' f z . fromSized
{-# inline foldr' #-}

-- | /O(n)/ Right fold on non-empty vectors with strict accumulator.
foldr1' :: VG.Vector v a => (a -> a -> a) -> Vector v (n+1) a -> a
foldr1' f = VG.foldr1' f . fromSized
{-# inline foldr1' #-}

-- | /O(n)/ Left fold (function applied to each element and its index).
ifoldl :: VG.Vector v b => (a -> Finite n -> b -> a) -> a -> Vector v n b -> a
ifoldl f z = VG.ifoldl (\x -> f x . Finite . fromIntegral) z . fromSized
{-# inline ifoldl #-}

-- | /O(n)/ Left fold with strict accumulator (function applied to each element
-- and its index).
ifoldl' :: VG.Vector v b => (a -> Finite n -> b -> a) -> a -> Vector v n b -> a
ifoldl' f z = VG.ifoldl' (\x -> f x . Finite . fromIntegral) z . fromSized
{-# inline ifoldl' #-}

-- | /O(n)/ Right fold (function applied to each element and its index).
ifoldr :: VG.Vector v a => (Finite n -> a -> b -> b) -> b -> Vector v n a -> b
ifoldr f z = VG.ifoldr (f . Finite . fromIntegral) z . fromSized
{-# inline ifoldr #-}

-- | /O(n)/ Right fold with strict accumulator (function applied to each
-- element and its index).
ifoldr' :: VG.Vector v a => (Finite n -> a -> b -> b) -> b -> Vector v n a -> b
ifoldr' f z = VG.ifoldr' (f . Finite . fromIntegral) z . fromSized
{-# inline ifoldr' #-}

-- ** Specialised folds

-- | /O(n)/ Check if all elements satisfy the predicate.
all :: VG.Vector v a => (a -> Bool) -> Vector v n a -> Bool
all f = VG.all f . fromSized
{-# inline all #-}

-- | /O(n)/ Check if any element satisfies the predicate.
any :: VG.Vector v a => (a -> Bool) -> Vector v n a -> Bool
any f = VG.any f . fromSized
{-# inline any #-}

-- | /O(n)/ Check if all elements are 'True'
and :: VG.Vector v Bool => Vector v n Bool -> Bool
and = VG.and . fromSized
{-# inline and #-}

-- | /O(n)/ Check if any element is 'True'
or :: VG.Vector v Bool => Vector v n Bool -> Bool
or = VG.or . fromSized
{-# inline or #-}

-- | /O(n)/ Compute the sum of the elements.
sum :: (VG.Vector v a, Num a) => Vector v n a -> a
sum = VG.sum . fromSized
{-# inline sum #-}

-- | /O(n)/ Compute the product of the elements.
product :: (VG.Vector v a, Num a) => Vector v n a -> a
product = VG.product . fromSized
{-# inline product #-}

-- | /O(n)/ Yield the maximum element of the non-empty vector.
maximum :: (VG.Vector v a, Ord a) => Vector v (n+1) a -> a
maximum = VG.maximum . fromSized
{-# inline maximum #-}

-- | /O(n)/ Yield the maximum element of the non-empty vector according to the
-- given comparison function.
maximumBy :: VG.Vector v a
          => (a -> a -> Ordering) -> Vector v (n+1) a -> a
maximumBy cmpr = VG.maximumBy cmpr . fromSized
{-# inline maximumBy #-}

-- | /O(n)/ Yield the minimum element of the non-empty vector.
minimum :: (VG.Vector v a, Ord a) => Vector v (n+1) a -> a
minimum = VG.minimum . fromSized
{-# inline minimum #-}

-- | /O(n)/ Yield the minimum element of the non-empty vector according to the
-- given comparison function.
minimumBy :: VG.Vector v a
          => (a -> a -> Ordering) -> Vector v (n+1) a -> a
minimumBy cmpr = VG.minimumBy cmpr . fromSized
{-# inline minimumBy #-}

-- | /O(n)/ Yield the index of the maximum element of the non-empty vector.
maxIndex :: (VG.Vector v a, Ord a) => Vector v (n+1) a -> Finite (n+1)
maxIndex = Finite . fromIntegral . VG.maxIndex . fromSized
{-# inline maxIndex #-}

-- | /O(n)/ Yield the index of the maximum element of the non-empty vector
-- according to the given comparison function.
maxIndexBy :: VG.Vector v a
           => (a -> a -> Ordering) -> Vector v (n+1) a -> Finite (n + 1)
maxIndexBy cmpr = Finite . fromIntegral . VG.maxIndexBy cmpr . fromSized
{-# inline maxIndexBy #-}

-- | /O(n)/ Yield the index of the minimum element of the non-empty vector.
minIndex :: (VG.Vector v a, Ord a) => Vector v (n+1) a -> Finite (n+1)
minIndex = Finite . fromIntegral . VG.minIndex . fromSized
{-# inline minIndex #-}

-- | /O(n)/ Yield the index of the minimum element of the non-empty vector
-- according to the given comparison function.
minIndexBy :: VG.Vector v a
           => (a -> a -> Ordering) -> Vector v (n+1) a -> Finite (n + 1)
minIndexBy cmpr = Finite . fromIntegral . VG.minIndexBy cmpr . fromSized
{-# inline minIndexBy #-}

-- ** Monadic folds

-- | /O(n)/ Monadic fold.
foldM :: (Monad m, VG.Vector v b) => (a -> b -> m a) -> a -> Vector v n b -> m a
foldM m z = VG.foldM m z . fromSized
{-# inline foldM #-}

-- | /O(n)/ Monadic fold (action applied to each element and its index).
ifoldM :: (Monad m, VG.Vector v b) => (a -> Finite n -> b -> m a) -> a -> Vector v n b -> m a
ifoldM m z = VG.ifoldM (\x -> m x . Finite . fromIntegral) z . fromSized
{-# inline ifoldM #-}

-- | /O(n)/ Monadic fold over non-empty vectors.
fold1M :: (Monad m, VG.Vector v a)
       => (a -> a -> m a) -> Vector v (1+n) a -> m a
fold1M m = VG.fold1M m . fromSized
{-# inline fold1M #-}

-- | /O(n)/ Monadic fold with strict accumulator.
foldM' :: (Monad m, VG.Vector v b) => (a -> b -> m a) -> a -> Vector v n b -> m a
foldM' m z = VG.foldM' m z . fromSized
{-# inline foldM' #-}

-- | /O(n)/ Monadic fold with strict accumulator (action applied to each
-- element and its index).
ifoldM' :: (Monad m, VG.Vector v b)
        => (a -> Finite n -> b -> m a) -> a -> Vector v n b -> m a
ifoldM' m z = VG.ifoldM' (\x -> m x . Finite . fromIntegral) z . fromSized
{-# inline ifoldM' #-}

-- | /O(n)/ Monadic fold over non-empty vectors with strict accumulator.
fold1M' :: (Monad m, VG.Vector v a)
        => (a -> a -> m a) -> Vector v (n+1) a -> m a
fold1M' m = VG.fold1M' m . fromSized
{-# inline fold1M' #-}

-- | /O(n)/ Monadic fold that discards the result.
foldM_ :: (Monad m, VG.Vector v b)
       => (a -> b -> m a) -> a -> Vector v n b -> m ()
foldM_ m z = VG.foldM_ m z . fromSized
{-# inline foldM_ #-}

-- | /O(n)/ Monadic fold that discards the result (action applied to
-- each element and its index).
ifoldM_ :: (Monad m, VG.Vector v b)
        => (a -> Finite n -> b -> m a) -> a -> Vector v n b -> m ()
ifoldM_ m z = VG.ifoldM_ (\x -> m x . Finite . fromIntegral)  z . fromSized
{-# inline ifoldM_ #-}

-- | /O(n)/ Monadic fold over non-empty vectors that discards the result.
fold1M_ :: (Monad m, VG.Vector v a)
        => (a -> a -> m a) -> Vector v (n+1) a -> m ()
fold1M_ m = VG.fold1M_ m . fromSized
{-# inline fold1M_ #-}

-- | /O(n)/ Monadic fold with strict accumulator that discards the result.
foldM'_ :: (Monad m, VG.Vector v b)
        => (a -> b -> m a) -> a -> Vector v n b -> m ()
foldM'_ m z = VG.foldM'_ m z . fromSized
{-# inline foldM'_ #-}

-- | /O(n)/ Monadic fold with strict accumulator that discards the result
-- (action applied to each element and its index).
ifoldM'_ :: (Monad m, VG.Vector v b)
         => (a -> Finite n -> b -> m a) -> a -> Vector v n b -> m ()
ifoldM'_ m z = VG.ifoldM'_ (\x -> m x . Finite . fromIntegral) z . fromSized
{-# inline ifoldM'_ #-}

-- | /O(n)/ Monad fold over non-empty vectors with strict accumulator
-- that discards the result.
fold1M'_ :: (Monad m, VG.Vector v a)
         => (a -> a -> m a) -> Vector v (n+1) a -> m ()
fold1M'_ m = VG.fold1M'_ m . fromSized
{-# inline fold1M'_ #-}

-- ** Monadic sequencing

-- | Evaluate each action and collect the results.
sequence :: (Monad m, VG.Vector v a, VG.Vector v (m a))
         => Vector v n (m a) -> m (Vector v n a)
sequence (Vector v) = Vector <$> VG.sequence v
{-# inline sequence #-}

-- | Evaluate each action and discard the results.
sequence_ :: (Monad m, VG.Vector v (m a)) => Vector v n (m a) -> m ()
sequence_ (Vector v) = VG.sequence_ v
{-# inline sequence_ #-}

--------------------------------------------------------------------------------
-- * Prefix sums (scans)
--------------------------------------------------------------------------------

-- | /O(n)/ Prescan
--
-- @
-- prescanl f z = 'init' . 'scanl' f z
-- @
--
-- Example: @prescanl (+) 0 \<1,2,3,4\> = \<0,1,3,6\>@
--
prescanl :: (VG.Vector v a, VG.Vector v b) => (a -> b -> a) -> a -> Vector v n b -> Vector v n a
prescanl f z = withVectorUnsafe (VG.prescanl f z )
{-# inline prescanl #-}

-- | /O(n)/ Prescan with strict accumulator.
prescanl' :: (VG.Vector v a, VG.Vector v b) => (a -> b -> a) -> a -> Vector v n b -> Vector v n a
prescanl' f z = withVectorUnsafe (VG.prescanl' f z )
{-# inline prescanl' #-}

-- | /O(n)/ Scan
postscanl :: (VG.Vector v a, VG.Vector v b) => (a -> b -> a) -> a -> Vector v n b -> Vector v n a
postscanl f z = withVectorUnsafe (VG.postscanl f z )
{-# inline postscanl #-}

-- | /O(n)/ Scan with strict accumulator.
postscanl' :: (VG.Vector v a, VG.Vector v b) => (a -> b -> a) -> a -> Vector v n b -> Vector v n a
postscanl' f z = withVectorUnsafe (VG.postscanl' f z )
{-# inline postscanl' #-}

-- | /O(n)/ Haskell-style scan.
scanl :: (VG.Vector v a, VG.Vector v b) => (a -> b -> a) -> a -> Vector v n b -> Vector v (1+n) a
scanl f z (Vector v) = Vector (VG.scanl f z v)
{-# inline scanl #-}

-- | /O(n)/ Haskell-style scan with strict accumulator.
scanl' :: (VG.Vector v a, VG.Vector v b) => (a -> b -> a) -> a -> Vector v n b -> Vector v (1+n) a
scanl' f z (Vector v) = Vector (VG.scanl' f z v)
{-# inline scanl' #-}

-- | /O(n)/ Scan over a non-empty vector.
scanl1 :: VG.Vector v a => (a -> a -> a) -> Vector v (1+n) a -> Vector v (2+n) a
scanl1 f (Vector v) = Vector (VG.scanl1 f v)
{-# inline scanl1 #-}

-- | /O(n)/ Scan over a non-empty vector with a strict accumulator.
scanl1' :: VG.Vector v a => (a -> a -> a) -> Vector v (1+n) a -> Vector v (2+n) a
scanl1' f (Vector v) = Vector (VG.scanl1' f v)
{-# inline scanl1' #-}

-- | /O(n)/ Right-to-left prescan.
prescanr :: (VG.Vector v a, VG.Vector v b) => (a -> b -> b) -> b -> Vector v n a -> Vector v n b
prescanr f z = withVectorUnsafe (VG.prescanr f z )
{-# inline prescanr #-}

-- | /O(n)/ Right-to-left prescan with strict accumulator.
prescanr' :: (VG.Vector v a, VG.Vector v b) => (a -> b -> b) -> b -> Vector v n a -> Vector v n b
prescanr' f z = withVectorUnsafe (VG.prescanr' f z )
{-# inline prescanr' #-}

-- | /O(n)/ Right-to-left scan.
postscanr :: (VG.Vector v a, VG.Vector v b) => (a -> b -> b) -> b -> Vector v n a -> Vector v n b
postscanr f z = withVectorUnsafe (VG.postscanr f z )
{-# inline postscanr #-}

-- | /O(n)/ Right-to-left scan with strict accumulator.
postscanr' :: (VG.Vector v a, VG.Vector v b) => (a -> b -> b) -> b -> Vector v n a -> Vector v n b
postscanr' f z = withVectorUnsafe (VG.postscanr' f z )
{-# inline postscanr' #-}

-- | /O(n)/ Right-to-left Haskell-style scan.
scanr :: (VG.Vector v a, VG.Vector v b) => (a -> b -> b) -> b -> Vector v n a -> Vector v (n+1) b
scanr f z (Vector v) = Vector (VG.scanr f z v)
{-# inline scanr #-}

-- | /O(n)/ Right-to-left Haskell-style scan with strict accumulator.
scanr' :: (VG.Vector v a, VG.Vector v b) => (a -> b -> b) -> b -> Vector v n a -> Vector v (n+1) b
scanr' f z (Vector v) = Vector (VG.scanr' f z v)
{-# inline scanr' #-}

-- | /O(n)/ Right-to-left scan over a non-empty vector.
scanr1 :: VG.Vector v a => (a -> a -> a) -> Vector v (n+1) a -> Vector v (n+2) a
scanr1 f (Vector v) = Vector (VG.scanr1 f v)
{-# inline scanr1 #-}

-- | /O(n)/ Right-to-left scan over a non-empty vector with a strict
-- accumulator.
scanr1' :: VG.Vector v a => (a -> a -> a) -> Vector v (n+1) a -> Vector v (n+2) a
scanr1' f (Vector v) = Vector (VG.scanr1' f v)
{-# inline scanr1' #-}


-- * Conversions

-- ** Lists

-- | /O(n)/ Convert a vector to a list.
toList :: VG.Vector v a => Vector v n a -> [a]
toList = VG.toList . fromSized
{-# inline toList #-}

-- | /O(n)/ Convert a list to a vector.
fromList :: (VG.Vector v a, KnownNat n) => [a] -> Maybe (Vector v n a)
fromList = toSized . VG.fromList
{-# inline fromList #-}

-- | /O(n)/ Convert the first @n@ elements of a list to a vector. The length of
-- the resultant vector is inferred from the type.
fromListN :: forall v n a. (VG.Vector v a, KnownNat n)
          => [a] -> Maybe (Vector v n a)
fromListN = toSized . VG.fromListN i
  where i = fromIntegral (natVal (Proxy :: Proxy n))
{-# inline fromListN #-}

-- | /O(n)/ Convert the first @n@ elements of a list to a vector. The length of
-- the resultant vector is given explicitly as a 'Proxy' argument.
fromListN' :: forall v n a p. (VG.Vector v a, KnownNat n)
           => p n -> [a] -> Maybe (Vector v n a)
fromListN' _ = fromListN
{-# inline fromListN' #-}

-- | /O(n)/ Takes a list and returns a continuation providing a vector with
-- a size parameter corresponding to the length of the list.
--
-- Essentially converts a list into a vector with the proper size
-- parameter, determined at runtime.
--
-- See 'withSized'
withSizedList :: forall v a r. VG.Vector v a
              => [a] -> (forall n. KnownNat n => Vector v n a -> r) -> r
withSizedList xs = withSized (VG.fromList xs)

-- ** Different Vector types

-- | /O(n)/ Convert different vector types.
convert :: (VG.Vector v a, VG.Vector w a) => Vector v n a -> Vector w n a
convert = withVectorUnsafe VG.convert
{-# inline convert #-}

-- ** Mutable vectors

-- | /O(n)/ Yield an immutable copy of the mutable vector.
freeze :: (PrimMonad m, VG.Vector v a)
       => SVGM.MVector (VG.Mutable v) n (PrimState m) a
       -> m (Vector v n a)
freeze (MVector v) = Vector <$> VG.freeze v

-- | /O(1)/ Unsafely convert a mutable vector to an immutable one withouy
-- copying. The mutable vector may not be used after this operation.
unsafeFreeze :: (PrimMonad m, VG.Vector v a)
             => SVGM.MVector (VG.Mutable v) n (PrimState m) a
             -> m (Vector v n a)
unsafeFreeze (MVector v) = Vector <$> VG.unsafeFreeze v

-- | /O(n)/ Yield a mutable copy of the immutable vector.
thaw :: (PrimMonad m, VG.Vector v a)
     => Vector v n a
     -> m (SVGM.MVector (VG.Mutable v) n (PrimState m) a)
thaw (Vector v) = MVector <$> VG.thaw v

-- | /O(n)/ Unsafely convert an immutable vector to a mutable one without
-- copying. The immutable vector may not be used after this operation.
unsafeThaw :: (PrimMonad m, VG.Vector v a)
           => Vector v n a
           -> m (SVGM.MVector (VG.Mutable v) n (PrimState m) a)
unsafeThaw (Vector v) = MVector <$> VG.unsafeThaw v

-- | /O(n)/ Copy an immutable vector into a mutable one.
copy :: (PrimMonad m, VG.Vector v a)
     => SVGM.MVector (VG.Mutable v) n (PrimState m) a
     -> Vector v n a
     -> m ()
copy (MVector v) (Vector u) = VG.unsafeCopy v u

-- ** Unsized vectors

-- | Convert a 'Data.Vector.Generic.Vector' into a
-- 'Data.Vector.Generic.Sized.Vector' if it has the correct size, otherwise
-- return Nothing.
toSized :: forall v n a. (VG.Vector v a, KnownNat n)
        => v a -> Maybe (Vector v n a)
toSized v
  | n' == fromIntegral (VG.length v) = Just (Vector v)
  | otherwise                        = Nothing
  where n' = natVal (Proxy :: Proxy n)
{-# inline toSized #-}

-- | Takes a 'Data.Vector.Generic.Vector' and returns a continuation
-- providing a 'Data.Vector.Generic.Sized' with a size parameter @n@ that
-- is determined at runtime based on the length of the input vector.
--
-- Essentially converts a 'Data.Vector.Generic.Vector' into
-- a 'Data.Vector.Generic.Sized.Vector' with the correct size parameter
-- @n@.
withSized :: forall v a r. VG.Vector v a
          => v a
          -> (forall n. KnownNat n => Vector v n a -> r) -> r
withSized v f = case someNatVal (fromIntegral (VG.length v)) of
  Just (SomeNat (Proxy :: Proxy n)) -> f (Vector v :: Vector v n a)
  Nothing -> error "impossible: Vector has negative length"

fromSized :: Vector v n a -> v a
fromSized (Vector v) = v
{-# inline fromSized #-}

-- | Apply a function on unsized vectors to a sized vector. The function must
-- preserve the size of the vector, this is not checked.
withVectorUnsafe :: (v a -> w b) -> Vector v n a -> Vector w n b
withVectorUnsafe f (Vector v) = Vector (f v)
{-# inline withVectorUnsafe #-}

-- | Apply a function on two unsized vectors to sized vectors. The function must
-- preserve the size of the vectors, this is not checked.
zipVectorsUnsafe :: (u a -> v b -> w c) -> Vector u n a -> Vector v n b -> Vector w n c
zipVectorsUnsafe f (Vector u) (Vector v) = Vector (f u v)
{-# inline zipVectorsUnsafe #-}

-- | Internal existential wrapper used for implementing 'SomeSized'
-- pattern synonym
data SV_ v a = forall n. KnownNat n => SV_ (Vector v n a)

-- | Pattern synonym that lets you treat an unsized vector as if it
-- "contained" a sized vector.  If you pattern match on an unsized vector,
-- its contents will be the /sized/ vector counterpart.
--
-- @
-- testFunc :: Unsized.Vector Int -> Int
-- testFunc ('SomeSized' v) =
--     'sum' ('zipWith' (+) v ('replicate' 1))
--         -- ^ here, v is `Sized.Vector n Int`, and we have
--                     `'KnownNat' n`
-- @
--
-- The @n@ type variable will be properly instantiated to whatever the
-- length of the vector is, and you will also have a @'KnownNat' n@
-- instance available.  You can get @n@ in scope by turning on
-- ScopedTypeVariables and matching on @'SomeSized' (v :: Sized.Vector
-- n Int)@.
--
-- Without this, you would otherwise have to use 'withSized' to do the same
-- thing:
--
-- @
-- testFunc :: Unsized.Vector Int -> Int
-- testFunc u = 'withSized' u $ \\v ->
--     'sum' ('zipWith' (+) v ('replicate' 1))
-- @
--
-- Remember that the type of final result of your function (the @Int@,
-- here) must /not/ depend on @n@.  However, the types of the intermediate
-- values are allowed to depend on @n@.
--
-- This is /especially/ useful in do blocks, where you can pattern match on
-- the unsized results of actions, to use the sized vector in the rest of
-- the do block.  You also get a @'KnownNat' n@ constraint for the
-- remainder of the do block.
--
-- @
-- -- If you had:
-- getAVector :: IO (Unsized.Vector Int)
--
-- main :: IO ()
-- main = do
--     SomeSized v <- getAVector -- v is `Sized.Vector n Int`
--     print v
--
--     -- alternatively, get n in scope
--     SomeSized (v2 :: Sized.Vector n Int) <- getAVector
--     print v2
-- @
--
-- Remember that the final type of the result of the do block ('()', here)
-- must not depend on @n@.  However, the
--
-- Also useful in ghci, where you can pattern match to get sized vectors
-- from unsized vectors.
--
-- @
-- ghci> SomeSized v <- pure (myUnsizedVector :: Unsized.Vector Int)
--              -- ^ v is `Sized.Vector n Int`
-- @
--
-- This enables interactive exploration with sized vectors in ghci, and is
-- useful for using with other libraries and functions that expect sized
-- vectors in an interactive setting.
--
-- (Note that as of GHC 8.6, you cannot get the @n@ in scope in your ghci
-- session using ScopedTypeVariables, like you can with do blocks)
--
-- You can also use this as a constructor, to take a sized vector and
-- "hide" the size, to produce an unsized vector:
--
-- @
-- SomeSized :: Sized.Vector n a -> Unsized.Vector a
-- @
--
-- Note that due to quirks in GHC pattern synonym completeness checking,
-- you will get incomplete pattern matches if you use this polymorphically
-- over different vector types, or you use any vector type other than the
-- three supported by this library (normal, storable, unboxed).
pattern SomeSized
    :: VG.Vector v a
    => forall n. KnownNat n
    => Vector v n a
    -> v a
pattern SomeSized v <- ((`withSized` SV_) -> SV_ v)
  where
    SomeSized v = fromSized v
{-# complete SomeSized :: Boxed.Vector    #-}
{-# complete SomeSized :: Unboxed.Vector  #-}
{-# complete SomeSized :: Storable.Vector #-}

instance (VG.Vector v a, Num a, KnownNat n) => Num (Vector v n a) where
    (+)         = zipWith (+)
    (-)         = zipWith (-)
    (*)         = zipWith (*)
    negate      = map negate
    abs         = map abs
    signum      = map signum
    fromInteger = replicate . fromInteger

instance (VG.Vector v a, Fractional a, KnownNat n) => Fractional (Vector v n a) where
    (/)          = zipWith (/)
    recip        = map recip
    fromRational = replicate . fromRational

instance (VG.Vector v a, Floating a, KnownNat n) => Floating (Vector v n a) where
    pi      = replicate pi
    exp     = map exp
    log     = map log
    sqrt    = map sqrt
    (**)    = zipWith (**)
    logBase = zipWith logBase
    sin     = map sin
    cos     = map cos
    tan     = map tan
    asin    = map asin
    acos    = map acos
    atan    = map atan
    sinh    = map sinh
    cosh    = map cosh
    tanh    = map tanh
    asinh   = map asinh
    acosh   = map acosh
    atanh   = map atanh

instance (VG.Vector v a, Binary a, KnownNat n) => Binary (Vector v n a) where
  get = replicateM Data.Binary.get
  put = mapM_ put

-- | Only usable if @v a@ is itself an instance of 'Bits', like in the case
-- with the bitvec library @Bit@ type for unboxed vectors.
instance (VG.Vector v a, Bits (v a), Bits a, KnownNat n) => Bits (Vector v n a) where
    (.&.) = coerce ((.&.) @(v a))
    (.|.) = coerce ((.|.) @(v a))
    xor   = coerce (xor   @(v a))
    complement = coerce (complement @(v a))
    rotate = coerce (rotate @(v a))
    rotateL = coerce (rotateL @(v a))
    rotateR = coerce (rotateR @(v a))
    bitSize x = case bitSizeMaybe x of
      Nothing -> error "Vector v n a: bitSize"
      Just c  -> c
    bitSizeMaybe _ = (* fromInteger (natVal (Proxy @n))) <$> bitSizeMaybe @a undefined
    isSigned _ = False
    testBit = coerce (testBit @(v a))
    popCount = coerce (popCount @(v a))
    setBit = coerce (setBit @(v a))
    complementBit = coerce (complementBit @(v a))
    -- need to do special stuff because they return a vector from scratch
    bit n = runST $ do
      v <- SVGM.replicate zeroBits
      for_ (packFinite (fromIntegral n)) $ \i ->
        SVGM.write v i (complement zeroBits)
      freeze v
    zeroBits = replicate zeroBits
    -- need to do special stuff because they have to preserve vector size
    shiftL xs i
      | i < 0     = Exception.throw Exception.Overflow
      | otherwise = unsafeShiftL xs i
    unsafeShiftL (Vector xs) i
        | i  == 0   = Vector xs
        | i' == n   = replicate zeroBits
        | otherwise = Vector $ runST $ do
            u <- VGM.replicate n zeroBits
            VG.unsafeCopy (VGM.unsafeDrop i' u) (VG.unsafeTake (n - i') xs)
            VG.unsafeFreeze u
      where
        n   = fromInteger $ natVal (Proxy @n)
        i' = min n i
    shiftR xs i
      | i < 0     = Exception.throw Exception.Overflow
      | otherwise = unsafeShiftR xs i
    unsafeShiftR (Vector xs) i
        | i  == 0   = Vector xs
        | i' == n   = replicate zeroBits
        | otherwise = Vector $ runST $ do
            u <- VGM.replicate n zeroBits
            VG.unsafeCopy (VGM.unsafeTake (n - i') u) (VG.unsafeDrop i' xs)
            VG.unsafeFreeze u
      where
        n  = fromInteger $ natVal (Proxy @n)
        i' = min n i

-- | Treats a bit vector as n times the size of the stored bits, reflecting
-- the 'Bits' instance; does not necessarily reflect exact in-memory
-- representation.  See 'Storable' instance to get information on the
-- actual in-memry representation.
instance (VG.Vector v a, Bits (v a), FiniteBits a, KnownNat n) => FiniteBits (Vector v n a) where
    finiteBitSize _ = finiteBitSize @a undefined * fromIntegral (natVal (Proxy @n))

-- | @since 1.6.0
instance IFunctor.FunctorWithIndex (Finite n) (Vector Boxed.Vector n) where
  {-# INLINEABLE imap #-}
  imap = imap

-- | @since 1.6.0
instance IFoldable.FoldableWithIndex (Finite n) (Vector Boxed.Vector n) where
  {-# INLINEABLE ifoldMap #-}
  ifoldMap f = ifoldl (\acc ix x -> acc `mappend` f ix x) mempty
  {-# INLINEABLE ifoldMap' #-}
  ifoldMap' f = ifoldl' (\acc ix x -> acc `mappend` f ix x) mempty
  {-# INLINEABLE ifoldr #-}
  ifoldr = ifoldr
  {-# INLINEABLE ifoldl #-}
  ifoldl f x = ifoldl (\acc ix -> f ix acc) x
  {-# INLINEABLE ifoldr' #-}
  ifoldr' = ifoldr'
  {-# INLINEABLE ifoldl' #-}
  ifoldl' f x = ifoldl' (\acc ix -> f ix acc) x

-- | @since 1.6.0
instance ITraversable.TraversableWithIndex (Finite n) (Vector Boxed.Vector n) where
  {-# INLINEABLE itraverse #-}
  itraverse f = traverse (uncurry f) . indexed
