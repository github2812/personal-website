(module
  ;; Request 1 page of memory (64KB) and export it to JavaScript
  (memory (export "memory") 1)

  ;; Export our function. It takes memory pointers (addresses) and lengths
  (func (export "process_vigenere")
    (param $text_ptr i32) (param $text_len i32)
    (param $key_ptr i32)  (param $key_len i32)
    (param $is_encrypt i32)

    ;; Setup local variables for our loop
    (local $i i32) (local $j i32)
    (local $t i32) (local $k i32) (local $shift i32)

    ;; If the key is empty, exit early
    local.get $key_len
    i32.eqz
    if return end

    ;; Start the character loop
    (loop $char_loop
      ;; Break loop if i >= text_len
      local.get $i
      local.get $text_len
      i32.ge_u
      br_if 1

      ;; Load text byte: t = memory[text_ptr + i]
      local.get $text_ptr
      local.get $i
      i32.add
      i32.load8_u
      local.set $t

      ;; Check if character is printable (>= 32 and <= 126)
      local.get $t
      i32.const 32
      i32.ge_s
      if
        local.get $t
        i32.const 126
        i32.le_s
        if
          ;; Load key byte: k = memory[key_ptr + j]
          local.get $key_ptr
          local.get $j
          i32.add
          i32.load8_u
          local.set $k

          ;; Calculate shift: shift = k % 95
          local.get $k
          i32.const 95
          i32.rem_u
          local.set $shift

          ;; Check if we are encrypting or decrypting
          local.get $is_encrypt
          if
            ;; Encrypt: t = t + shift
            local.get $t
            local.get $shift
            i32.add
            local.set $t

            ;; Wrap around if t > 126
            local.get $t
            i32.const 126
            i32.gt_s
            if
              local.get $t
              i32.const 95
              i32.sub
              local.set $t
            end
          else
            ;; Decrypt: t = t - shift
            local.get $t
            local.get $shift
            i32.sub
            local.set $t

            ;; Wrap under if t < 32
            local.get $t
            i32.const 32
            i32.lt_s
            if
              local.get $t
              i32.const 95
              i32.add
              local.set $t
            end
          end

          ;; Advance key index: j = (j + 1) % key_len
          local.get $j
          i32.const 1
          i32.add
          local.get $key_len
          i32.rem_u
          local.set $j
        end
      end

      ;; Store modified byte back: memory[text_ptr + i] = t
      local.get $text_ptr
      local.get $i
      i32.add
      local.get $t
      i32.store8

      ;; i++
      local.get $i
      i32.const 1
      i32.add
      local.set $i

      ;; Jump back to top of loop
      br $char_loop
    )
  )
)