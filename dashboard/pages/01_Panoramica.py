"""Panoramica — KPI del sistema universitario italiano."""

import pandas as pd
import plotly.graph_objects as go
import streamlit as st

from sources import fmt_num, load_mart, YEARS

st.title("Panoramica")
st.caption("Il sistema universitario italiano in numeri")

year = st.selectbox("Anno", YEARS, index=len(YEARS) - 1)

# Load: il file contiene TUTTI gli anni, filtro dopo
df_all = load_mart("mur_iscritti", "mart_iscritti_concentrazione", 2025)
df = df_all[df_all["anno"] == year]

if df.empty:
    st.warning("Dati non disponibili.")
    st.stop()

# KPI
k1, k2, k3, k4 = st.columns(4)
totale = int(df["totale"].sum())
donne = int(df["donne"].sum())
pct_donne = 100.0 * donne / totale if totale > 0 else 0

k1.metric("Iscritti", fmt_num(totale))
k2.metric("Atenei", fmt_num(df["ateneo_cod"].nunique()))
k3.metric("% Donne", f"{pct_donne:.1f}%")
k4.metric("Anno", str(year))

st.divider()

# Trend
st.subheader("Trend iscrizioni")
trend = df_all.groupby("anno", as_index=False).agg(totale=("totale", "sum"), donne=("donne", "sum"), uomini=("uomini", "sum"))
fig = go.Figure()
fig.add_trace(go.Scatter(x=trend["anno"], y=trend["totale"], name="Totale", mode="lines+markers", line=dict(color="#6366f1", width=3)))
fig.add_trace(go.Scatter(x=trend["anno"], y=trend["donne"], name="Donne", mode="lines", line=dict(color="#ec4899", width=2, dash="dot")))
fig.add_trace(go.Scatter(x=trend["anno"], y=trend["uomini"], name="Uomini", mode="lines", line=dict(color="#3b82f6", width=2, dash="dot")))
fig.update_layout(height=350, yaxis_title="Iscritti", xaxis_title="Anno", margin={"t": 20, "b": 40}, legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1))
st.plotly_chart(fig, width="stretch")

st.divider()

# Top 10 + geo
col_left, col_right = st.columns([2, 1])
with col_left:
    st.subheader("Top 10 atenei")
    top10 = df.nlargest(10, "totale")
    fig_top = go.Figure(go.Bar(x=top10["totale"], y=top10["ateneo_nome"], orientation="h", marker_color="#6366f1", text=top10["totale"].apply(lambda x: fmt_num(int(x))), textposition="outside"))
    fig_top.update_layout(height=400, xaxis_title="Iscritti", yaxis=dict(categoryorder="array", categoryarray=top10["ateneo_nome"].tolist()[::-1]), margin={"l": 200, "r": 20, "t": 10, "b": 40}, showlegend=False)
    st.plotly_chart(fig_top, width="stretch")

with col_right:
    st.subheader("Macro-area")
    df_geo = df.groupby("macro_area", as_index=False).agg(totale=("totale", "sum"))
    fig_pie = go.Figure(go.Pie(labels=df_geo["macro_area"], values=df_geo["totale"], hole=0.4, marker_colors=["#6366f1", "#3b82f6", "#22c55e", "#f59e0b", "#ef4444"]))
    fig_pie.update_layout(height=400, margin={"t": 20, "b": 20}, showlegend=True, legend=dict(orientation="h", yanchor="bottom", y=-0.2))
    st.plotly_chart(fig_pie, width="stretch")
