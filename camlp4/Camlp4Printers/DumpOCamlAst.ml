(****************************************************************************)
(*                                                                          *)
(*                              Objective Caml                              *)
(*                                                                          *)
(*                            INRIA Rocquencourt                            *)
(*                                                                          *)
(*  Copyright  2006   Institut National de Recherche  en  Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed under   *)
(*  the terms of the GNU Library General Public License, with the special   *)
(*  exception on linking described in LICENSE at the top of the Objective   *)
(*  Caml source tree.                                                       *)
(*                                                                          *)
(****************************************************************************)

(* Authors:
 * - Daniel de Rauglaudre: initial version
 * - Nicolas Pouillard: refactoring
 *)
open Camlp4;                                        (* -*- camlp4r -*- *)

module Id : Sig.Id.S = struct
  value name = "Camlp4Printers.DumpOCamlAst";
  value version = "$Id$";
end;

module Make (Syntax : Sig.Camlp4Syntax.S)
: Sig.Printer.S with module Ast = Syntax.Ast
= struct
  include Syntax;
  module Ast2pt = Struct.Camlp4Ast2OCamlAst.Make Ast;

  value with_open_out_file x f =
    match x with
    [ Some file -> do { let oc = open_out_bin file in f oc;
                        flush oc;
                        close_out oc }
    | None -> do { set_binary_mode_out stdout True; f stdout; flush stdout } ];

  value dump_pt magic fname pt oc = do {
    output_string oc magic;
    output_value oc (if fname = "-" then "" else fname);
    output_value oc pt;
  };

  value print_interf ?(input_file = "-") ?output_file ast =
    let pt = Ast2pt.sig_item ast in
    with_open_out_file output_file (dump_pt Config.ocaml_ast_intf_magic_number input_file pt);

  value print_implem ?(input_file = "-") ?output_file ast =
    let pt = Ast2pt.str_item ast in
    with_open_out_file output_file (dump_pt Config.ocaml_ast_impl_magic_number input_file pt);

end;

let module M = Register.OCamlPrinter Id Make in ();