import streamlit as st
import snowflake.connector
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

# ── Page config ──────────────────────────────────────────────
st.set_page_config(
    page_title="E-commerce Analytics Dashboard",
    page_icon="🛒",
    layout="wide"
)

# ── Connexion Snowflake ───────────────────────────────────────
@st.cache_resource
def get_connection():
    creds = st.secrets["snowflake"]
    return snowflake.connector.connect(
        account=creds["account"],
        user=creds["user"],
        password=creds["password"],
        warehouse=creds["warehouse"],
        database=creds["database"],
        schema=creds["schema"],
        role=creds["role"]
    )

@st.cache_data(ttl=3600)
def run_query(query):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(query)
    df = pd.DataFrame(
        cursor.fetchall(),
        columns=[col[0] for col in cursor.description]
    )
    return df

# ── Header ───────────────────────────────────────────────────
st.title("🛒 E-commerce Analytics Dashboard")
st.markdown("**Data source:** Olist Brazilian E-commerce · "
            "**Warehouse:** Snowflake · **Transform:** dbt")
st.divider()

# ── Load data ─────────────────────────────────────────────────
monthly    = run_query("SELECT * FROM STAGING.RPT_MONTHLY_KPIS ORDER BY YEAR_MONTH")
categories = run_query("SELECT * FROM STAGING.RPT_REVENUE_BY_CATEGORY ORDER BY TOTAL_REVENUE DESC LIMIT 15")
customers  = run_query("""
    SELECT CUSTOMER_SEGMENT, COUNT(*) AS total
    FROM STAGING.DIM_CUSTOMERS
    GROUP BY CUSTOMER_SEGMENT
""")
fct = run_query("""
    SELECT
        AVG(DELIVERY_DAYS)                              AS avg_delivery,
        SUM(CASE WHEN DELIVERED_ON_TIME THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*)                          AS on_time_rate,
        AVG(REVIEW_SCORE)                               AS avg_review,
        SUM(ORDER_TOTAL)                                AS total_revenue,
        COUNT(DISTINCT ORDER_ID)                        AS total_orders
    FROM STAGING.FCT_ORDERS
    WHERE ORDER_TOTAL > 0
""")

# ── KPI Cards ─────────────────────────────────────────────────
st.subheader("📊 Key Performance Indicators")

col1, col2, col3, col4, col5 = st.columns(5)

total_rev    = fct["TOTAL_REVENUE"].iloc[0]
total_orders = fct["TOTAL_ORDERS"].iloc[0]
avg_delivery = fct["AVG_DELIVERY"].iloc[0]
on_time      = fct["ON_TIME_RATE"].iloc[0]
avg_review   = fct["AVG_REVIEW"].iloc[0]

col1.metric("💰 Total Revenue",     f"R$ {total_rev:,.0f}")
col2.metric("📦 Total Orders",      f"{total_orders:,.0f}")
col3.metric("🚚 Avg Delivery Days", f"{avg_delivery:.1f} days")
col4.metric("✅ On-time Delivery",  f"{on_time:.1f}%")
col5.metric("⭐ Avg Review Score",  f"{avg_review:.2f} / 5")

st.divider()

# ── Row 1 : Revenue + Orders ──────────────────────────────────
col_left, col_right = st.columns(2)

with col_left:
    st.subheader("📈 Monthly Revenue (BRL)")
    fig = px.area(
        monthly,
        x="YEAR_MONTH",
        y="TOTAL_REVENUE",
        color_discrete_sequence=["#1f77b4"],
        labels={"YEAR_MONTH": "Month", "TOTAL_REVENUE": "Revenue (BRL)"}
    )
    fig.update_layout(showlegend=False)
    st.plotly_chart(fig, use_container_width=True)

with col_right:
    st.subheader("📦 Monthly Orders")
    fig = px.bar(
        monthly,
        x="YEAR_MONTH",
        y="TOTAL_ORDERS",
        color_discrete_sequence=["#2ca02c"],
        labels={"YEAR_MONTH": "Month", "TOTAL_ORDERS": "Orders"}
    )
    fig.update_layout(showlegend=False)
    st.plotly_chart(fig, use_container_width=True)

st.divider()

# ── Row 2 : Categories + Customer segments ────────────────────
col_left, col_right = st.columns(2)

with col_left:
    st.subheader("🏆 Top 15 Categories by Revenue")
    fig = px.bar(
        categories,
        x="TOTAL_REVENUE",
        y="PRODUCT_CATEGORY_NAME",
        orientation="h",
        color="TOTAL_REVENUE",
        color_continuous_scale="Blues",
        labels={
            "TOTAL_REVENUE": "Revenue (BRL)",
            "PRODUCT_CATEGORY_NAME": "Category"
        }
    )
    fig.update_layout(showlegend=False, yaxis={"categoryorder": "total ascending"})
    st.plotly_chart(fig, use_container_width=True)

with col_right:
    st.subheader("👥 Customer Segments")
    fig = px.pie(
        customers,
        values="TOTAL",
        names="CUSTOMER_SEGMENT",
        color_discrete_sequence=["#1f77b4", "#ff7f0e", "#2ca02c"],
        hole=0.4
    )
    fig.update_traces(textposition="inside", textinfo="percent+label")
    st.plotly_chart(fig, use_container_width=True)

st.divider()

# ── Row 3 : Delivery + Satisfaction ──────────────────────────
col_left, col_right = st.columns(2)

with col_left:
    st.subheader("🚚 Avg Delivery Days by Month")
    fig = px.line(
        monthly,
        x="YEAR_MONTH",
        y="AVG_DELIVERY_DAYS",
        markers=True,
        color_discrete_sequence=["#d62728"],
        labels={"YEAR_MONTH": "Month", "AVG_DELIVERY_DAYS": "Days"}
    )
    st.plotly_chart(fig, use_container_width=True)

with col_right:
    st.subheader("⭐ Avg Review Score by Month")
    fig = px.line(
        monthly,
        x="YEAR_MONTH",
        y="AVG_REVIEW_SCORE",
        markers=True,
        color_discrete_sequence=["#9467bd"],
        labels={"YEAR_MONTH": "Month", "AVG_REVIEW_SCORE": "Score (1-5)"}
    )
    fig.update_layout(yaxis=dict(range=[1, 5]))
    st.plotly_chart(fig, use_container_width=True)

# ── Footer ────────────────────────────────────────────────────
st.divider()
st.markdown(
    "Built by **Bachir** · "
    "[GitHub](https://github.com/bachir00) · "
    "[LinkedIn](https://www.linkedin.com/in/bassirou-kane-525529227/)"
)