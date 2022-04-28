import 'package:app_flowy/startup/startup.dart';
import 'package:app_flowy/workspace/application/grid/prelude.dart';
import 'package:app_flowy/workspace/presentation/plugins/grid/src/widgets/cell/cell_builder.dart';
import 'package:flowy_infra/theme.dart';
import 'package:flowy_infra_ui/style_widget/text.dart';
// ignore: unused_import
import 'package:flowy_sdk/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'extension.dart';
import 'selection_editor.dart';

class SelectOptionCellStyle extends GridCellStyle {
  String placeholder;

  SelectOptionCellStyle({
    required this.placeholder,
  });
}

class SingleSelectCell extends GridCellWidget {
  final GridCellContextBuilder cellContextBuilder;
  late final SelectOptionCellStyle? cellStyle;

  SingleSelectCell({
    required this.cellContextBuilder,
    GridCellStyle? style,
    Key? key,
  }) : super(key: key) {
    if (style != null) {
      cellStyle = (style as SelectOptionCellStyle);
    } else {
      cellStyle = null;
    }
  }

  @override
  State<SingleSelectCell> createState() => _SingleSelectCellState();
}

class _SingleSelectCellState extends State<SingleSelectCell> {
  late SelectionCellBloc _cellBloc;

  @override
  void initState() {
    // Log.trace("init widget $hashCode");
    final cellContext = _buildCellContext();
    _cellBloc = getIt<SelectionCellBloc>(param1: cellContext)..add(const SelectionCellEvent.initial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();
    // Log.trace("build widget $hashCode");
    return BlocProvider.value(
      value: _cellBloc,
      child: BlocBuilder<SelectionCellBloc, SelectionCellState>(
        builder: (context, state) {
          List<Widget> children = [];
          children.addAll(state.selectedOptions.map((option) => SelectOptionTag(option: option)).toList());

          if (children.isEmpty && widget.cellStyle != null) {
            children.add(FlowyText.medium(widget.cellStyle!.placeholder, fontSize: 14, color: theme.shader3));
          }
          return SizedBox.expand(
            child: InkWell(
              onTap: () {
                widget.onFocus.value = true;
                SelectOptionCellEditor.show(
                  context,
                  _buildCellContext(),
                  () => widget.onFocus.value = false,
                );
              },
              child: ClipRRect(child: Row(children: children)),
            ),
          );
        },
      ),
    );
  }

  GridSelectOptionCellContext _buildCellContext() {
    return widget.cellContextBuilder.build() as GridSelectOptionCellContext;
  }

  @override
  Future<void> dispose() async {
    // Log.trace("dispose widget $hashCode");
    _cellBloc.close();
    super.dispose();
  }
}

//----------------------------------------------------------------
class MultiSelectCell extends GridCellWidget {
  final GridCellContextBuilder cellContextBuilder;
  late final SelectOptionCellStyle? cellStyle;

  MultiSelectCell({
    required this.cellContextBuilder,
    GridCellStyle? style,
    Key? key,
  }) : super(key: key) {
    if (style != null) {
      cellStyle = (style as SelectOptionCellStyle);
    } else {
      cellStyle = null;
    }
  }

  @override
  State<MultiSelectCell> createState() => _MultiSelectCellState();
}

class _MultiSelectCellState extends State<MultiSelectCell> {
  late SelectionCellBloc _cellBloc;

  @override
  void initState() {
    final cellContext = _buildCellContext();
    _cellBloc = getIt<SelectionCellBloc>(param1: cellContext)..add(const SelectionCellEvent.initial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cellBloc,
      child: BlocBuilder<SelectionCellBloc, SelectionCellState>(
        builder: (context, state) {
          List<Widget> children = state.selectedOptions.map((option) => SelectOptionTag(option: option)).toList();

          if (children.isEmpty && widget.cellStyle != null) {
            children.add(FlowyText.medium(widget.cellStyle!.placeholder, fontSize: 14));
          }

          return SizedBox.expand(
            child: InkWell(
              onTap: () {
                widget.onFocus.value = true;
                SelectOptionCellEditor.show(
                  context,
                  _buildCellContext(),
                  () => widget.onFocus.value = false,
                );
              },
              child: ClipRRect(child: Row(children: children)),
            ),
          );
        },
      ),
    );
  }

  @override
  Future<void> dispose() async {
    _cellBloc.close();
    super.dispose();
  }

  GridSelectOptionCellContext _buildCellContext() {
    return widget.cellContextBuilder.build() as GridSelectOptionCellContext;
  }
}